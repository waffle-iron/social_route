module ApiHelper
  require 'date'

  def allowed_accounts
    ['act_1219094644772149', 'act_1219093434772270', 'act_1219094751438805',
     'act_1219094488105498', 'act_1219616701386610', 'act_1130403580307923',
     'act_1139120289436252', 'act_1130403223641292', 'act_1253619597986320',
     'act_1264926836855596', 'act_1374748469467327', 'act_937799526234997',
     'act_1382151058724804', 'act_1382716158668218', 'act_1096482140366734',
     'act_1382519912021865', 'act_923549197660030', 'act_256023237923821',
     'act_1033441906670758', 'act_965932350088381', 'act_1380511028896841',
     'act_1219093704772243', 'act_1219094968105450', 'act_944470208901262',
     'act_331941523628320']
  end

  def account_dates(account_id)
    start = Ad2.where(account_id: account_id).order('date_start').first.date_start.to_date
    stop  = Ad2.where(account_id: account_id).order('date_stop').last.date_stop.to_date
    return "#{start.strftime('%B %e, %Y')} - #{stop.strftime('%b %e, %Y')}"
  end
end
