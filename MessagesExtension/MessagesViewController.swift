//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Colin Witkamp on 7/29/16.
//  Copyright © 2016 cw. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    //var boardView : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Properties
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        
        // Present the view controller appropriate for the conversation and presentation style.
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    // MARK: MSMessagesAppViewController
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        guard let conversation = activeConversation else { fatalError("Expected an active converstation") }
        
        // Present the view controller appropriate for the conversation and presentation style.
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    // MARK: Child view controller presentation
    
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        print("UUID: " + conversation.localParticipantIdentifier.uuidString)
        
        // Determine the controller to present.
        let controller: UIViewController
        //controller = instantiateGameHistoryViewController()
        var players = [Player]()
        for participant in conversation.remoteParticipantIdentifiers {
            players.append(Player(uuid: participant.uuidString, color: UIColor.random()))
        }
        
        let game = TicTacToe(message: conversation.selectedMessage, current: conversation.localParticipantIdentifier.uuidString) ?? TicTacToe(player:  Player(uuid: conversation.localParticipantIdentifier.uuidString, color: #colorLiteral(red: 0.3607843137, green: 0.6235294118, blue: 0.9607843137, alpha: 1)), opponents: players)
        
        controller = instantiateGameViewController(with: game)
        
        if game.player.uuid != conversation.localParticipantIdentifier.uuidString || !game.containsUserWith(uuid: conversation.localParticipantIdentifier.uuidString) {
            fatalError("Not a participant in the game")
        }
        
        // Remove any existing child controllers.
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        // Embed the new controller.
        addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        controller.didMove(toParentViewController: self)
        
        
    }
    
    /*private func instantiateGameHistoryViewController() -> UIViewController {
     // Instantiate a `IceCreamsViewController` and present it.
     guard let controller = storyboard?.instantiateViewController(withIdentifier: GameHistoryViewController.storyboardIdentifier) as? GameHistoryViewController else { fatalError("Unable to instantiate an IceCreamsViewController from the storyboard") }
     
     controller.delegate = self
     
     return controller
     }*/
    
    func instantiateGameViewController(with game: TicTacToe) -> UIViewController {
        // Instantiate a `BuildIceCreamViewController` and present it.
        guard let controller = storyboard?.instantiateViewController(withIdentifier: GameViewController.storyboardIdentifier) as? GameViewController else { fatalError("Unable to instantiate a GameViewController from the storyboard") }
        
        controller.game = game
        controller.delegate = self
        
        return controller
    }
    
    // MARK: Convenience
    
    func composeMessage(with game: TicTacToe, caption: String, image: UIImage, session: MSSession? = nil) -> MSMessage {
        var components = URLComponents()
        components.queryItems = game.queryItems
        
        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = caption
        
        let message = MSMessage(session: session ?? MSSession())
        message.url = components.url!
        message.layout = layout
        
        return message
    }
}

extension MessagesViewController: GameViewControllerDelegate {
    func gameViewController(_ controller: GameViewController, renderedImage: UIImage) {
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        guard let game = controller.game else { fatalError("Expected the controller to be displaying a game") }
        
        let message = self.composeMessage(with: game, caption: NSLocalizedString("", comment: ""), image: renderedImage, session: conversation.selectedMessage?.session)
        
        conversation.insert(message) { error in
            if let error = error {
                print(error)
            }
        }
        
        
        
        /*if game.winner != nil {
         //var history = GamesHistory.load()
         //history.append(game)
         //history.save()
         }*/
        
        dismiss()
    }
    
    func requestNewGame() {
        // Remove any existing child controllers.
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        var players = [Player]()
        for participant in activeConversation!.remoteParticipantIdentifiers {
            players.append(Player(uuid: participant.uuidString, color: UIColor.random()))
        }
        
        let game = TicTacToe(player:  Player(uuid: activeConversation!.localParticipantIdentifier.uuidString, color: #colorLiteral(red: 0.3607843137, green: 0.6235294118, blue: 0.9607843137, alpha: 1)), opponents: players)
        
        let controller = self.instantiateGameViewController(with: game)
        
        // Embed the new controller.
        addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        controller.didMove(toParentViewController: self)
    }
}

extension UIColor {
    static func random() -> UIColor {
        let randomRed: CGFloat = CGFloat(drand48())
        let randomGreen: CGFloat = CGFloat(drand48())
        let randomBlue: CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}
