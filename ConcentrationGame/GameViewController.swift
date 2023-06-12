//
//  GameViewController.swift
//  ConcentrationGame
//
//  Created by Ya Yu Yeh on 2023/2/22.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var cardsBtns: [UIButton]!
    @IBOutlet weak var secLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    var timer = Timer()
    let animals = ["鼠","牛","虎","兔","龍","蛇","馬","羊","猴","雞","狗","豬"]
    var allCards = [String]()
    var timeShowing = 10
    var pickedNums = [Int]()
    var score = 0
    
    // - MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showRandomCards()
        countdown(sec: 10, action: #selector(timerForMemory(_:)))
    }
    
    // - MARK: Defined Function
    func showRandomCards(){
        //洗牌
        allCards = animals + animals
        allCards.shuffle()
        //取得index來獲得所有圖片名稱，並將圖片放進對應的按鈕位置
        for (i,_) in allCards.enumerated(){
            cardsBtns[i].configuration?.background.image = UIImage(named: allCards[i])
        }
    }

    //秒數尚未帶入 -> for memory & game 需觀察是否可結合
    func countdown(sec:Int, action:Selector){
        //先保證目前無timer
        timer.invalidate()
        timeShowing = sec
        secLbl.text = "\(timeShowing)"
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: action, userInfo: nil, repeats: true)
    }
    
    //宣告訊息視窗函式
    func alert(title:String, message:String, action1:String?, action2:String?, handler: ((UIAlertAction)->Void)?){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: action1, style: .default, handler: handler)
        alertController.addAction(action1)
        if action2 != nil{
            let action2 = UIAlertAction(title: action2, style: .destructive)
            alertController.addAction(action2)
        }
        present(alertController, animated: true)
    }
    
    func flip(button:UIButton, index:Int){
        //背面時，翻正面圖案
        if button.configuration?.background.image == UIImage(named: "mark"){
            cardsBtns[index].configuration?.background.image = UIImage(named: allCards[index])
            UIView.transition(with: cardsBtns[index], duration: 0.3, options: .transitionFlipFromTop, animations: nil, completion: nil)
        }else{
            //正面時，翻背面圖案 -> 用在已翻牌且判斷兩張牌是否相同時
            cardsBtns[index].configuration?.background.image = UIImage(named: "mark")
            UIView.transition(with: cardsBtns[index], duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        }
    }
    
    func replay(){
        print("replay preparing")
        score = 0
        scoreLbl.text = "\(score)/12"
        countdown(sec: 10, action: #selector(timerForMemory(_:)))
        showRandomCards()
        pickedNums.removeAll()
    }

    // - MARK: Target Action
    @objc func timerForMemory(_ time:Timer){
        timeShowing -= 1
        secLbl.text = "\(timeShowing)"
        //秒數歸零，準備遊戲開始：
        if timeShowing == 0{
            self.timer.invalidate()
            //按鈕翻面轉為問號圖案
            for cardsBtn in self.cardsBtns{
                cardsBtn.configuration?.background.image = UIImage(named: "mark")
                UIView.transition(with: cardsBtn, duration: 1, options: .transitionFlipFromRight, animations: nil)
            }
            alert(title: "Game start", message: "Good luck :)", action1: "OK", action2: nil) { _ in
                //選擇題視窗中的OK，開始60秒遊戲計時
                self.countdown(sec: 60, action: #selector(self.timerForGame(_:)))
            }
        }
    }
    
    @objc func timerForGame(_ time:Timer){
        timeShowing -= 1
        secLbl.text = "\(timeShowing)"
        //秒數歸零，遊戲結束：
        if timeShowing == 0 || score == 12 {
            //遊戲結束後，按鈕不可被翻面
            self.timer.invalidate()
            //倒數結束後出現提示視窗，可選擇結束遊戲或是啟動replay
            alert(title: "Well done.", message: "Your score : \(score)/12", action1: "Replay", action2: "Thanks") { _ in
                self.replay()
            }
        }
    }
    
    @IBAction func openCards(_ sender: UIButton) {
        //判斷點擊的按鈕在哪一個位置
        if let cardNum = cardsBtns.firstIndex(of: sender){
            //必須為背面圖案才能執行翻牌及執行判斷
            if sender.configuration?.background.image == UIImage(named: "mark"){
                flip(button: sender, index: cardNum)
                print("\(cardNum)\(allCards[cardNum])")
                pickedNums.append(cardNum)
                if pickedNums.count == 2{
                    //翻兩張牌後，不可再翻第三張牌
                    for i in 0..<cardsBtns.count{ cardsBtns[i].isEnabled = false }
                    //點擊兩次後，判斷兩張按鈕圖片是否相同
                    if allCards[pickedNums[0]] == allCards[pickedNums[1]]{
                        //判斷相同後，可繼續翻牌
                        for i in 0..<cardsBtns.count{ cardsBtns[i].isEnabled = true }
                        pickedNums.removeAll()
                        score += 1
                        scoreLbl.text = "\(score)/12"
                        print("the same")
                    }else{
                        //延遲觸發，等待兩張牌皆打開後再翻回背面
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.6){
                            //判斷不相同後，翻回背面且可繼續翻牌
                            for i in 0..<self.cardsBtns.count{ self.cardsBtns[i].isEnabled = true }
                            for i in 0..<self.pickedNums.count{
                                self.flip(button: self.cardsBtns[self.pickedNums[i]], index: self.pickedNums[i])
                            }
                            self.pickedNums.removeAll()
                            print("different")
                        }
                    }
                }
            }
        }
    }
}
