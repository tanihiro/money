require "rubygems"
require "google/api_client"
require "google_drive"
require "nokogiri"
require "open-uri"

client = Google::APIClient.new
auth = client.authorization
auth.client_id = "529200646319-a00krdt8vh20p19j8far50nm58egddkc.apps.googleusercontent.com"
auth.client_secret = "XmAek2XtzoTBDmXMCr97RR-e"
auth.scope =
    "https://www.googleapis.com/auth/drive " +
    "https://spreadsheets.google.com/feeds/"
auth.redirect_uri = "https://www.example.com/oauth2callback"
print("1. Open this page:\n%s\n\n" % auth.authorization_uri)
print("2. Enter the authorization code shown in the page: ")
auth.code = $stdin.gets.chomp
auth.fetch_access_token!
access_token = auth.access_token

# Creates a session.
session = GoogleDrive.login_with_oauth(access_token)

ws = session.spreadsheet_by_key('1IgHX8ke8Zlh0uIoF5BD5s3aNT_wWiBpbzFXVNaFby3g').worksheets[0]

ws.rows.each.with_index(1) do |row, index|
  url = row[3]
  next unless url =~ /https?:\/\//

  html = Nokogiri::HTML(open(url))
  name = html.css('h1').first.content
  price = html.css('.stoksPrice')[1].content

  p "name: #{name}, price: #{price}"

  ws[index, 2] = name
  ws[index, 3] = price
end

ws.save
