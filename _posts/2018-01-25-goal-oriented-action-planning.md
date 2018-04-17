---
layout: post
title:  "Goal Oriented Action Planning"
date:   2018-01-25
categories: goap ai goal oriented action planning unity gamedev
published: false
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

### Goals

### Actions

### Planner

## Implementation

Note: I decided to use JS for this example because it's ubiquitous and easy to translate into other languages. While this is a functional GOAP implementation, I must warn you that it's fairly naive. A better implementation (in C#) is [ReGoap](https://github.com/luxkun/ReGoap) so if you're looking to use GOAP in production I would start there. [GPGOAP](https://github.com/stolk/GPGOAP) is another great example.

Lastly, I would like to say that this is just my interpretation of GOAP. If you're interested in the source behind these ideas please check out Jeff Orkin's article [here](http://alumni.media.mit.edu/~jorkin/gdc2006_orkin_jeff_fear.pdf).
