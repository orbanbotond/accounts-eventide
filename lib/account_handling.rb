# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)
require 'messaging'
require 'entity_projection'
require 'entity_store'
require 'debug'

# Withdraw command message
# Send to the account component to effect a withdrawal
class Withdraw
  include Messaging::Message

  attribute :account_id, String
  attribute :amount, Numeric
  attribute :time, String
end

# Account command handler with withdrawal implementation
# Business logic for processing a withdrawal
class Handler
  include Messaging::Handle

  attr_writer :store, :stream

  handle Withdraw do |withdraw|
    account_id = withdraw.account_id
    account = @store.fetch(account_id)

    return false unless account.sufficient_funds?(withdraw.amount)

    withdrawn = Withdrawn.follow(withdraw)

    withdrawn.processed_time = Time.now.to_s

    @stream << withdrawn
  end
end

# Withdrawn event message
# Event is written by the handler when a withdrawal is successfully processed
class Withdrawn
  include Messaging::Message

  attribute :account_id, String
  attribute :amount, Numeric
  attribute :time, String
  attribute :processed_time, String
end

# Account entity
# The account component's model object
class Account
  include Schema::DataStructure

  attribute :id, String
  attribute :balance, Numeric, default: -> { 0 }

  def withdraw(amount)
    self.balance -= amount
  end

  def sufficient_funds?(amount)
    balance >= amount
  end
end

# Account entity projection
# Applies account events to an account entity
class Projection
  include EntityProjection

  entity_name :account

  apply Withdrawn do |withdrawn|
    # TODO: this should be read only
    # account.id = withdrawn.account_id
    account.withdraw(withdrawn.amount)
  end
end

# Account entity store
# Projects an account entity and keeps a cache of the result
class Store
  include EntityStore

  entity Account
  projection Projection
end
