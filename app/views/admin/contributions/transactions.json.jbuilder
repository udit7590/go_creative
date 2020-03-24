json.contribution_id @contribution.id

json.transactions @transactions do |transaction|
  
  json.id transaction.authorization
  json.db_id transaction.id
  json.timestamp Time.at(transaction.params['created']).to_s(:long)
  json.action transaction.action.humanize
  json.amount number_to_currency(transaction.amount, unit: 'INR ', precision: 0)

end
