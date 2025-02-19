class HeadlessBrowserPdfGenerator
  PAGE_LOAD_TIMEOUT = 2 # seconds

  def self.call(url)
    new(url).call
  end

  def initialize(url)
    @url = url
  end

  def call
    generate_pdf
  end

  private

  def generate_pdf
    temp_pdf = Tempfile.new([ "document", ".pdf" ])
    browser = create_browser
    generate_pdf_with_browser(browser, temp_pdf)
    temp_pdf
  rescue Ferrum::Error => e
    raise Error::UnprocessableEntityError, "Failed to generate PDF: #{e.message}"
  end

  def create_browser
    browser_configs = Rails.application.credentials.headless_browser.fetch(Rails.env.to_sym)
    Ferrum::Browser.new(browser_configs)
  end

  def generate_pdf_with_browser(browser, temp_pdf)
    page = browser.create_page
    page.go_to(@url)
    wait_for_page_load(page)
    page.pdf(path: temp_pdf.path)
    page.close
  ensure
    browser.quit
  end

  def wait_for_page_load(page)
    sleep(PAGE_LOAD_TIMEOUT)
  end
end
