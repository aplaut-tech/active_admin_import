# frozen_string_literal: true
module ActiveAdminImport
  class ImportResult
    attr_reader :failed, :total, :ids

    def initialize
      @failed = []
      @total = 0
      @ids = []
    end

    def add(result, qty)
      @failed += result.failed_instances
      @ids    += result.ids
      @total  += qty
    end

    def imported_qty
      total - failed.count
    end

    def imported?
      imported_qty > 0
    end

    def failed?
      failed.any?
    end

    def empty?
      total == 0
    end

    def failed_message(options = {})
      limit = options[:limit] || failed.count
      failed.first(limit).map do |record|
        errors = record.errors
        failed_values = attribute_names_for(errors).map do |key|
          key == :base ? nil : record.public_send(key)
        end
        errors.full_messages.zip(failed_values).map { |ms| ms.compact.join(' - ') }.join(', ')
      end.join(' ; ')
    end

    private

    def attribute_names_for(errors)
      if Gem::Version.new(Rails.version) >= Gem::Version.new('7.0')
        errors.attribute_names
      else
        errors.keys
      end
    end
  end
end
