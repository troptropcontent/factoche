require "nokogiri"

module Accounting
  module FacturX
    class GenerateXml
      include ApplicationService

      TEMPORARY_FAKE_IBAN= "FR7617499123451234567890153".freeze
      TEMPORARY_FAKE_BIC= "LOYDCHGGZCH".freeze

      def call(invoice_id, configs = {})
          @configs = YAML.load_file(Rails.root.join("config/facturx_defaults.yml")).merge(configs)
          @invoice = Invoice.find(invoice_id)

          builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
            xml["rsm"].CrossIndustryInvoice(@configs.fetch("main_tag_attributes")) do
              build_document_context(xml)
              build_exchanged_document(xml)
              build_supply_chain_transaction(xml)
            end
          end

          xml_string = builder.to_xml

          write_to_tempfile(xml_string)
      end

      private

      def build_document_context(xml)
        xml["rsm"].ExchangedDocumentContext do
          xml["ram"].BusinessProcessSpecifiedDocumentContextParameter do
            xml["ram"].ID @configs.fetch("business_process_id")
          end
          xml["ram"].GuidelineSpecifiedDocumentContextParameter do
            xml["ram"].ID @configs.fetch("guideline_id")
          end
        end
      end

      def build_exchanged_document(xml)
        xml["rsm"].ExchangedDocument do
          xml["ram"].ID @invoice.number
          xml["ram"].TypeCode @configs.fetch("typecodes").fetch("invoice")
          xml["ram"].IssueDateTime do
            xml["udt"].DateTimeString(@invoice.issue_date.strftime("%Y%m%d"), format: @configs.fetch("date_time_format_code"))
          end

          # HERE SHOULD GO ANY INCLUDED NOTES
          # (@invoice[:notes] || []).each do |note|
          #   xml["ram"].IncludedNote do
          #     xml["ram"].Content note[:content]
          #     xml["ram"].SubjectCode note[:subject_code]
          #   end
          # end
        end
      end

      def build_supply_chain_transaction(xml)
        xml["rsm"].SupplyChainTradeTransaction do
          (@invoice.lines).each do |line|
            build_trade_line_item(xml, line)
          end

          build_header_trade_agreement(xml)
          build_header_trade_delivery(xml)
          build_header_trade_settlement(xml)
        end
      end

      def build_trade_line_item(xml, line)
        item = item(line.holder_id)
        xml["ram"].IncludedSupplyChainTradeLineItem do
          xml["ram"].AssociatedDocumentLineDocument do
            xml["ram"].LineID item["original_item_uuid"]
          end
          xml["ram"].SpecifiedTradeProduct do
            xml["ram"].Name item["name"]
            xml["ram"].Description(item["description"]) if item["description"]
          end
          xml["ram"].SpecifiedLineTradeAgreement do
            xml["ram"].GrossPriceProductTradePrice do
              xml["ram"].ChargeAmount line.excl_tax_amount.to_s
              xml["ram"].BasisQuantity(line.quantity.to_s, unitCode: @configs.fetch("quantity").fetch("unit_code"))
            end
            xml["ram"].NetPriceProductTradePrice do
              xml["ram"].ChargeAmount line.excl_tax_amount
              xml["ram"].BasisQuantity(line.quantity.to_s, unitCode: @configs.fetch("quantity").fetch("unit_code"))
            end
          end
          xml["ram"].SpecifiedLineTradeDelivery do
            xml["ram"].BilledQuantity(line.quantity.to_s, unitCode: @configs.fetch("quantity").fetch("unit_code"))
          end
          xml["ram"].SpecifiedLineTradeSettlement do
            xml["ram"].ApplicableTradeTax do
              xml["ram"].TypeCode "VAT"
              xml["ram"].CategoryCode "K"
              xml["ram"].RateApplicablePercent (line.tax_rate * 100).round(2).to_s
            end
            xml["ram"].SpecifiedTradeSettlementLineMonetarySummation do
              xml["ram"].LineTotalAmount (line.excl_tax_amount * (1 + line.tax_rate)).round(2).to_s
            end
          end
        end
      end

      def build_header_trade_agreement(xml)
        xml["ram"].ApplicableHeaderTradeAgreement do
          xml["ram"].SellerTradeParty do
            xml["ram"].Name @invoice.detail.seller_name
            xml["ram"].PostalTradeAddress do
              xml["ram"].PostcodeCode @invoice.detail.seller_address_zipcode
              xml["ram"].LineOne @invoice.detail.seller_address_street
              xml["ram"].CityName @invoice.detail.seller_address_city
              xml["ram"].CountryID @configs.fetch("country")
            end
            xml["ram"].SpecifiedTaxRegistration do
              xml["ram"].ID(@invoice.detail.seller_vat_number, schemeID: @configs.fetch("specified_tax_registration_code"))
            end
          end

          xml["ram"].BuyerTradeParty do
            xml["ram"].Name @invoice.detail.client_name
            xml["ram"].PostalTradeAddress do
              xml["ram"].PostcodeCode @invoice.detail.client_address_zipcode
              xml["ram"].LineOne @invoice.detail.client_address_street
              xml["ram"].CityName @invoice.detail.client_address_city
              xml["ram"].CountryID @configs.fetch("country")
            end
            xml["ram"].SpecifiedTaxRegistration do
              xml["ram"].ID(@invoice.detail.client_vat_number, schemeID: @configs.fetch("specified_tax_registration_code"))
            end
          end
        end
      end

      def build_header_trade_delivery(xml)
        xml["ram"].ApplicableHeaderTradeDelivery do
          if @invoice[:delivery_date]
            xml["ram"].ActualDeliverySupplyChainEvent do
              xml["ram"].OccurrenceDateTime do
                xml["udt"].DateTimeString(@invoice.issue_date.strftime("%Y%m%d"), format: @configs.fetch("date_time_format_code"))
              end
            end
          end
        end
      end

      def build_header_trade_settlement(xml)
        xml["ram"].ApplicableHeaderTradeSettlement do
          xml["ram"].InvoiceCurrencyCode @configs.fetch("currency")

          xml["ram"].SpecifiedTradeSettlementPaymentMeans do
            xml["ram"].TypeCode @configs.fetch("payment_means").fetch("type_code")
            xml["ram"].Information @configs.fetch("payment_means").fetch("information")
            xml["ram"].PayeePartyCreditorFinancialAccount do
              xml["ram"].IBANID TEMPORARY_FAKE_IBAN
            end
            xml["ram"].PayeeSpecifiedCreditorFinancialInstitution do
              xml["ram"].BICID TEMPORARY_FAKE_BIC
            end
          end

          xml["ram"].ApplicableTradeTax do
            xml["ram"].CalculatedAmount "0.00"
            xml["ram"].TypeCode "VAT"
            xml["ram"].BasisAmount @invoice.total_excl_tax_amount.to_s
            xml["ram"].CategoryCode "Z"
            xml["ram"].RateApplicablePercent "0.00"
          end

          xml["ram"].SpecifiedTradeSettlementHeaderMonetarySummation do
            xml["ram"].LineTotalAmount @invoice.total_excl_tax_amount.to_s
            xml["ram"].TaxBasisTotalAmount @invoice.total_excl_tax_amount.to_s
            xml["ram"].TaxTotalAmount (@invoice.total_including_tax_amount - @invoice.total_excl_tax_amount).round(2).to_s
            xml["ram"].GrandTotalAmount @invoice.total_including_tax_amount.to_s
            xml["ram"].DuePayableAmount @invoice.total_including_tax_amount.to_s
          end
        end
      end

      def write_to_tempfile(xml_string)
        tempfile = Tempfile.new([ "#{@invoice.number}", ".xml" ])
        tempfile.write(xml_string)
        tempfile.rewind
        tempfile
      end

      def item(holder_id)
        Hash.new { |h, k| h[k] = @invoice.context["project_version_items"].find { |item| item["original_item_uuid"] == holder_id } }[holder_id]
      end
    end
  end
end
