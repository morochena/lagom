---
layout: post
title:  "Stripe with Phoenix"
date:   2017-06-20
slug: "osx-password-hash-extraction"
description: "How to set up Stripe with Phoenix"
categories: elixir phoenix stripe
published: false
---

# Overall Strategy

So the overall idea is that you'll have a SAAS app that can offer subscriptions that customers can subscribe do, and pay for on a recurring basis. Obviously setting up a payment gateway yourself is most likely not in your best interest, so using a service like Stripe will allow you do handle these things easily.

Essentially, what we have to do is as follows:

1. Allow accounts to register locally, which creates a corresponding Stripe user (that is referenced by our local model)
2. Pull in subscription plans from Stripe, store locally in our app
3. Create a form where a user can choose a plan
4. Set up Stripe Checkout
5. Create subscription from Stripe checkout result
6. Write logic for cancelling subscriptions (& updating locally)
7. Write logic for changing subscriptions 
8. Subscription events, webhooks

Our models are going to look like this:

``` elixir  

  schema "customer_accounts" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :stripe_customer_id, :string

    has_many :products, Soba.Products.Product
    has_one :subscription, Soba.Billing.Subscription

    belongs_to :plan, Soba.Billing.Plan
  end

  schema "billing_plans" do
    field :amount, :integer
    field :description, :string
    field :name, :string
    field :stripe_id, :string

    timestamps()
  end
```

