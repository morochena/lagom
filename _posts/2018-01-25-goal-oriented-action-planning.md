---
layout: post
title:  "Goal Oriented Action Planning Concepts"
date:   2018-01-25
categories: goap ai goal oriented action planning unity gamedev
published: true
---

Goal Oriented Action Planning is a technique used in AI development to help reduce complexity for the programmer when designing complex state transitions. GOAP allows a programmer to specify goals for an AI, and lets it figure out the best sequence of actions to achieve that goal instead of explicitly telling it what to do. In the context of game development it's very suited for games focused on emergent gameplay with complex AI interactions. That being said, it's not a silver bullet. It's relatively costly to compute and it won't add behaviors that you wouldn't be able to otherwise implement. One way to look at it is that you're trading CPU time for development time.

Commonly game AI developers use [Finite State Machines](https://en.wikipedia.org/wiki/Finite-state_machine) to model the execution of AI behavior. FSMs are computational models that describe a series of states that a computational machine can be in, and transitions between them. A machine can only be in one state at a time, and transitions are conditionally activated, so it's easy to understand the execution flow of the machine. 

To illustrate, this is an example of a very simple Zombie AI modeled as a FSM.

![Zombie FSM Example](/assets/images/Zombie FSM.png)

- A zombie will chase a human, unless it's eating
- A zombie will attack a human until it dies
- If a zombie loses sight of a human, it will go back to wandering
- If a zombie sees a corpse it will begin eating it 

These states and transitions are coded directly, and an example state could look like this:

``` ruby
class WanderState < FSMState

  # called when entering the state
  def on_enter(actor)
    
  end

  # the current state's execute() method is called every frame
  def execute(actor) 
    if actor.sees_food?
      actor.transition(EatState)

    elsif actor.sees_human?
      actor.transition(ChaseState)

    else
      actor.continue_wander()
  end

  # called when transitioning out of the state
  def on_exit(actor)
    actor.speed += 10 # he's hungry!
  end
end
```

If the zombie is in this state, he will wander until he sees food or a human and then transition into the appropriate state and increase his speed. Easy!

This is a great technique and is widely used in AI programming. However, you can already see that to add a new state, you would have to account for and create all possible transitions to and from all of the existing states. This might be fine for the example, but what if you have 20, 30, or 100? Also, any more complex sequences of transitions (for "smarter" AI) would also need to be hard coded. It's definitely possible, but can get complicated quickly. 

This is where GOAP comes in. It builds upon FSMs - you're still creating the states, but you're removing the hard coded transitions. Instead, you're simply giving the AI *Goals*, and arming them with *Actions* to achieve them. GOAP will generate the sequence of actions necessary to achieve the AI's goals, without hard coding the behavior in.

How does it work? We'll go into detail below, but simple terms you can think of GOAP dynamically generating FSMs based on its goals, environment, and available actions.

## Components of GOAP

### Agent 

This is the 'brain' of the entity that is being managed by the AI. It has a list of goals and available actions. It also usually keeps track of its environment, often implemented in terms of 'sensors', which is outside the scope of this post. 

### Goals

These are the primary directives of the agent. When the agent is planning it's action sequence, it's attempts to meet these goals.

Goal Examples:
```
Name: Has a Sword
Name: Not Hungry
```

### Actions

These are things that an agent can do which change the state of the the world. Generally the consist of a list of preconditons which must be met to execute the action, as well as a list of postconditions (or 'effects') that happen once they've done the action. They also have an associated 'energy' cost which the Planner will use to to help determine the most efficient series of actions to achieve a goal. 

Action Example:
``` 
Action: 'Mine Ore', 
Preconditions: ['Has Pick', 'Not Tired', 'Inventory not Full'], 
Effects: ['Adds 1 Ore to Inventory']
```

### Planner

## Implementation

Coming up next. :)
