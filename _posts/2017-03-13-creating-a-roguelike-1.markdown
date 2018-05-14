---
layout: post
title:  "Creating a Roguelike: Part 1"
date:   2017-03-13
slug: "creating-a-roguelike-part-1"
description: "I've always wanted to write a roguelike, so I thought I'd document my process."
published: false
---

I've always wanted to write a roguelike, so I thought I'd document my process.

A couple things to get out of the way before we start:

* I'm not an experienced roguelike player. I've played maybe 100 hours of DCSS, Brogue, ADOM, some TOME and Caves of Qud. I haven't played Rogue or Nethack yet.
* I haven't read that much about roguelike design, so I may unknowingly commit blashelphmy against established standard practices.
* I'm probably going to use sprites instead of ASCII. I think people have done wonderful things with ASCII, but I feel like sprites are more expressive.
* My goal is to get a playable game, I'm not going to obsess over details. I want to have a shippable verison within 80 development hours.
* This will be more a repository of thoughts than a tutorial.

_A note on format:_ I'm not sure writing everything out that I'm doing will be time efficient or even beneficial to anyone. I think I'm just going to explain what I'm doing, and have a repostiroy and link specific tags in the project.

# Design Goals

So for me, the first step to making a game is to come up with some ideas that I can get excited about. I want to figure out the following:

* Theme
* Core Gameplay
* Character creation
* Enemies
* Combat system
* Level system
* Unique gameplay element

# Theme

In an effort to do something kind of original, let's turn the traditional "wanderer hero delving into a dungeon and fighting monsters" on it's head.

How about in this game, you're a monster who has been captured and incarcerated by humans on an island prison. One morning you wake up to a lot of noise - your prison cell is unlocked, and you can hear pandemonium outside. There's a large jail-break! This is your chance to escape. But be warned, the humans are doing everything in their power to keep control of the prison, and other monsters may not be friendly.

Welcome to "Escape from Monster Island"!

# Core Gameplay

* Turn Based
* Procederually Generated Levels
* Gain power through levels and equipment
* Flexibility in terms of escaping

I want enemies to be unique in that they have to be dealt with in different ways. You should be able to feel the difference when fighting something like a kobold vs an ogre - and you should have to deal with them in different ways. I'll flesh this out more later.

## Character Creation

I'm a big fan of DCSS - I think the racial/class combos are a great way to express creativity and serve to influence the difficulty. On the other hand, I really like Brogue which forces you to adapt your playstyle based on the situation. Also, I think real, organic skill accrual (ie. actually learning how to use your character better) always trumps artificial increases (ie. you gain 5 strength and 5 hp) in terms of satisfaction. I think what I'll do is have all characters start the same way, but then have them be customizeable throughout your playthrough based on your preferences.

Races:

* Orc
  * brutes, not too smart or charismatic
* Ghost
  * very stealthy, weak
* Vampire
  * charismatic, stealthy
* Demon
  * many different types
* Changingling
  * very weak, can turn into other creatures

Classes:

* Fighter
  * your traditional hack n slash duder
* Rogue
  * stealthy duder
* Overlord
  * control other monsters

## Combat system...

Hmm.

## Level system...

I don't have many thoughts on this yet.

# Technical Requirements

* I think the game should be easily accessible (no downloads or installs).
* It's also going to be free and open source.
* I don't really want to deal with cross platform builds, I'd prefer to use a universal platform like the web.
* It's going to be 2d, no need for fancy graphics but I would like to render to a canvas of some kind.
* Primarily keyboard-driven input, _maybe_ mouse input for buttons.

Yes, this means _shudder_ **javascript**... but we still have some options! We could use one of the many languages that transpiles to JS - like Purescript, Elm, Clojurescript, etc - and that's what we're going to do.

In terms of software architecture, there are a couple goals I have:

* Complete separation of game logic from UI.
* Composition over inheritance
* An Entity Component System for managing complex system interactions
