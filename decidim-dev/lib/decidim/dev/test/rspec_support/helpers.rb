# frozen_string_literal: true

# Helpers that get automatically included in component specs.
module Decidim::ComponentTestHelpers
  def click_submenu_link(text)
    within ".secondary-nav--subnav" do
      click_link text
    end
  end

  def within_user_menu
    within ".topbar__user__logged" do
      find("a", text: user.name).click
      yield
    end
  end

  def within_language_menu
    within ".topbar__dropmenu.language-choose" do
      find("ul.dropdown.menu").click
      yield
    end
  end

  def stripped(text)
    text.gsub(/^<p>/, "").gsub(%r{</p>$}, "")
  end

  def within_flash_messages
    within ".flash" do
      yield
    end
  end

  def expect_user_logged
    expect(page).to have_css(".topbar__user__logged")
  end

  def have_admin_callout(text)
    have_selector(".callout--full", text:)
  end

  def stub_get_request_with_format(rq_url, rs_format)
    stub_request(:get, rq_url)
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "User-Agent" => "Ruby"
        }
      )
      .to_return(status: 200, body: "", headers: { content_type: rs_format })
  end
end

RSpec.configure do |config|
  config.include Decidim::ComponentTestHelpers, type: :system
end
