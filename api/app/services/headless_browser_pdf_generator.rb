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
    Ferrum::Browser.new({
      ws_url: "#{ENV.fetch("HEADLESS_BROWSER_WS")}?token=#{ENV.fetch("HEADLESS_BROWSER_TOKEN")}",
      process: false
    })
  end

  def generate_pdf_with_browser(browser, temp_pdf)
    page = browser.create_page
    page.go_to(@url)
    wait_for_page_load(page)
    if page.network.status != 200
      raise Error::UnprocessableEntityError, "Failed to load page: print server responded with a #{page.network.status}"
    end
    page.pdf(path: temp_pdf.path)
    page.close
  ensure
    browser.quit
  end

  def wait_for_page_load(page)
    sleep(PAGE_LOAD_TIMEOUT)
  end
end
