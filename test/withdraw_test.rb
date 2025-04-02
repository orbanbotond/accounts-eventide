require_relative './test_helper'
require_relative '../lib/account_handling'

context 'Handler' do
  store = {}
  account = Account.new
  account.id = 'Boti'
  account.balance = 15
  store[account.id] = account

  stream = []
  handler = Handler.new
  handler.store = store
  handler.stream = stream

  context 'Too much' do
    too_much_withdrawal_from_boti = Withdraw.new
    too_much_withdrawal_from_boti.account_id = 'Boti'
    too_much_withdrawal_from_boti.amount = 16

    test do
      handler.call(too_much_withdrawal_from_boti)
      assert(account.balance == 15)
      assert(stream.length == 0)
    end
  end

  context 'Success' do
    max_withdrawal_from_boti = Withdraw.new
    max_withdrawal_from_boti.account_id = 'Boti'
    max_withdrawal_from_boti.amount = 15

    test do
      handler.call(max_withdrawal_from_boti)
      assert(stream.length == 1)
    end
  end
end

context 'Projection' do
  store = {}
  account = Account.new
  account.id = 'Boti'
  account.balance = 15
  store[account.id] = account

  withdrawal_from_boti = Withdrawn.new
  withdrawal_from_boti.account_id = 'Boti'
  withdrawal_from_boti.amount = 14

  stream = []
  stream << withdrawal_from_boti
  projection = Projection.new(account)

  context 'Project' do
    projection.call(withdrawal_from_boti)

    test do
      assert(account.balance == 1)
    end
  end
end
