class_name State extends Node


signal finished(nextState:String, flags:Dictionary)

func enter(oldState:String, flags:Dictionary):
    pass

func exit(newState:String, flags:Dictionary):
    pass

func update(delta:float):
    pass

func physicsUpdate(delta:float):
    pass

func handleInput(event:InputEvent):
    pass
