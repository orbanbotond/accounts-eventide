require_relative './test_helper'
require_relative '../lib/account_handling'

context "Withdraw" do
  store = {}
  account = Account.new
  account.id = 'Boti'
  account.balance = 15
  store[account.id] = account

  stream = []
  handler = Handler.new
  handler.store = store
  handler.stream = stream

  context "Too much" do
    too_much_withdrawal_from_boti = Withdraw.new
    too_much_withdrawal_from_boti.account_id = 'Boti'
    too_much_withdrawal_from_boti.amount = 16

    test do
      handler.(too_much_withdrawal_from_boti)
      assert(account.balance == 15)
      assert(stream.length == 0)
    end
  end

  context "Success" do
    too_much_withdrawal_from_boti = Withdraw.new
    too_much_withdrawal_from_boti.account_id = 'Boti'
    too_much_withdrawal_from_boti.amount = 15

    test do
      handler.(too_much_withdrawal_from_boti)
      # assert(account.balance == 0)
      assert(stream.length == 1)
    end
  end
end
