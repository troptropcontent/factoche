class Accounting::FinancialYear < ApplicationRecord
  has_many :financial_transactions, class_name: "Accounting::FinancialTransaction"
  validates :start_date, :end_date, presence: true
  validate :dates_consistency, :no_overlapping_exercises

  private

  def dates_consistency
    return unless start_date && end_date

    if end_date <= start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def no_overlapping_exercises
    return unless company_id && start_date && end_date

    overlapping =       self.class
                        .where(company_id: company_id)
                        .where.not(id: id)
                        .where(
                          "(start_date <= ? AND end_date >= ?) OR " \
                          "(start_date <= ? AND end_date >= ?) OR " \
                          "(start_date >= ? AND end_date <= ?)",
                          start_date, start_date,  # New period starts during existing
                          end_date, end_date,      # New period ends during existing
                          start_date, end_date     # New period encompasses existing
                        )

    if overlapping.exists?
      errors.add(:base, "dates overlap with existing financial year")
    end
  end
end
