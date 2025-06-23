require 'rails_helper'
# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe HeadlessBrowserPdfGenerator do
  describe '.call' do
    let(:url) { 'https://example.com/invoice' }
    let(:browser_double) { instance_double(Ferrum::Browser) }
    let(:page_double) { instance_double(Ferrum::Page) }
    let(:network_double) { instance_double(Ferrum::Network) }
    let(:print_server_status) { 200 }
    let(:temp_file) { instance_double(Tempfile, path: '/tmp/test.pdf') }

    before do
      allow(Tempfile).to receive(:new).and_return(temp_file)
      allow(Ferrum::Browser).to receive(:new).and_return(browser_double)
      allow(browser_double).to receive(:create_page).and_return(page_double)
      allow(browser_double).to receive(:quit)
      allow(page_double).to receive(:go_to)
      allow(page_double).to receive(:network).and_return(network_double)
      allow(network_double).to receive(:status).and_return(print_server_status)
      allow(page_double).to receive(:pdf)
      allow(page_double).to receive(:close)
    end

    it 'generates a PDF file from the given URL', :aggregate_failures do
      result = described_class.call(url)

      expect(page_double).to have_received(:go_to).with(url)
      expect(page_double).to have_received(:pdf).with(path: temp_file.path)
      expect(result).to eq(temp_file)
    end

    context 'when PDF generation fails' do
      before do
        allow(page_double).to receive(:go_to)
          .and_raise(Ferrum::Error.new('Failed to load page'))
      end

      it 'raises an UnprocessableEntityError' do
        expect {
          described_class.call(url)
        }.to raise_error(Error::UnprocessableEntityError, /Failed to generate PDF/)
      end
    end
  end

  describe 'integration', :slow do
    let(:test_html) do
      <<~HTML
        <!DOCTYPE html>
        <html>
          <head><title>Test PDF</title></head>
          <body>
            <h1>Test PDF Generation</h1>
            <p>Generated at: #{Time.current}</p>
          </body>
        </html>
      HTML
    end

    let(:response_status) { 200 }
    let(:server_port) { 3999 } # Use a fixed port
    let(:server_host) { ENV["SERVER_HOST"] || "app" } # Use a fixed port
    let(:url) { "http://#{server_host}:#{server_port}" }
    let(:server) do
      WEBrick::HTTPServer.new(
        Port: server_port,
        BindAddress: '0.0.0.0',
        Logger: WEBrick::Log.new('/dev/null'),
        AccessLog: []
      )
    end

    before do
      WebMock.allow_net_connect!

      server.mount_proc '/' do |_, response|
        response.content_type = 'text/html'
        response.status = response_status
        response.body = test_html
      end

      Thread.new { server.start }

      sleep 2
    end

    after do
      WebMock.disable_net_connect!
      server.shutdown
    end


    context "when the server responde with a 200" do
      it 'generates a valid PDF file from a real web page', :aggregate_failures do
        result = described_class.call(url)

        expect(result).to be_a(Tempfile)
        expect(File.exist?(result.path)).to be true

        # Verify it's a valid PDF
        pdf_content = File.read(result.path, mode: 'rb')
        expect(pdf_content[0..3]).to eq('%PDF')

        result.close
        result.unlink
      end
    end

    context "when the server responde with a non 200" do
      let(:response_status) { 404 }

      it 'raises an error', :aggregate_failures do
        expect { described_class.call(url) }.to raise_error('Failed to load page: print server responded with a 404')
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
