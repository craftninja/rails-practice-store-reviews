require 'spec_helper'

feature 'shopping for products' do
  before do
    DatabaseCleaner.clean
  end

  def log_in(user)
    visit '/'
    click_link 'Login'
    fill_in 'session[email]', with: user.email
    fill_in 'session[password]', with: user.password
    click_button 'Login'
  end

  scenario 'Guest can view existing products' do
    author = Author.create!(first_name: 'Arthur', last_name: 'Radcliffe')
    publisher = Publisher.create!(name: 'Arthur Books', city: 'Denver')
    Product.create!(
      name: 'Test Book',
      hardcover_price_in_cents: 1000,
      softcover_price_in_cents: 800,
      description: 'This is a description',
      image_url: 'http://fc04.deviantart.net/fs70/f/2012/306/d/c/fahrenheit_451__movie_poster_by_trzytrzy-d5jrq21.jpg',
      published_date: '1/1/2010',
      author_id: author.id,
      publisher_id: publisher.id
    )

    visit '/'

    within('.product') do
      expect(page).to have_content 'Test Book'
      expect(page).to have_content '(Jan 1, 2010)'
      expect(page).to have_content 'Radcliffe'
      expect(page).to have_content 'Arthur Books'
    end
  end

  scenario 'Admins can create a product and view its show page' do
    author = Author.create!(first_name: 'Arthur', last_name: 'Radcliffe')
    publisher = Publisher.create!(name: 'Arthur Books', city: 'Denver')
    admin = User.create!(email: 'admin@example.com', password: 'password1', admin: true)
    log_in(admin)

    visit '/'
    click_link 'Add Product'

    fill_in 'product[name]', with: "Making Bricks With 3D-Printers"
    fill_in 'product[hardcover_price]', with: "$19.99"
    fill_in 'product[softcover_price]', with: 9.99
    fill_in 'product[description]', with: "This is the description"
    page.attach_file("product[image_url]", "#{Rails.root}/spec/assets/download.jpeg")
    fill_in 'product[published_date]', with: "1/1/2014"
    select 'Arthur Radcliffe', from: 'Author'
    select 'Arthur Books', from: 'Publisher'
    click_on 'Save Product'

    expect(current_path).to eq '/'
    expect(page).to have_content 'Product successfully added'
    product = Product.last

    expect(page).to have_content "Radcliffe"
    expect(page).to have_content "Arthur Books"
    expect(page).to have_content "(Jan 1, 2014)"
    expect(page).to have_content "19.99"
    expect(page).to have_content "(Softcover)"
    expect(page).to have_xpath("//img[@src=\"/uploads/product/image_url/#{product.id}/download.jpeg\"]")

    click_link "Making Bricks With 3D-Printers"

    expect(page).to have_content "Making Bricks With 3D-Printers"
    expect(page).to have_content "Radcliffe"
    expect(page).to have_content "Arthur Books"
    expect(page).to have_content "(Jan 1, 2014)"
    expect(page).to have_content "9.99"
    expect(page).to have_content "(Softcover)"
    expect(page).to have_xpath("//img[@src=\"/uploads/product/image_url/#{product.id}/download.jpeg\"]")
  end

  scenario 'Error is displayed when Author or Publisher are left blank' do
    admin = User.create!(email: 'drunk_admin@example.com', password: 'password1', admin: true)
    log_in(admin)

    visit '/products/new'

    fill_in 'product[name]', with: "Making Bricks With 3D-Printers"
    fill_in 'product[hardcover_price]', with: 19.99
    fill_in 'product[softcover_price]', with: 9.99
    fill_in 'product[description]', with: "This is the description"
    page.attach_file("product[image_url]", "#{Rails.root}/spec/assets/download.jpeg")
    fill_in 'product[published_date]', with: "1/1/2014"

    click_on 'Save Product'

    expect(page).to have_content 'Author can\'t be blank'
    expect(page).to have_content 'Publisher can\'t be blank'

    expect(current_path).to eq '/products'
  end

  scenario 'Non-admins cannot add products' do
    visit '/'
    expect(page).to_not have_link 'Add Product'

    visit '/products/new'

    expect(current_path).to eq '/'
    expect(page).to have_content 'Access Denied'

    # ensure logged in users are also denied access
    non_admin = User.create!(email: 'admin@example.com', password: 'password1', admin: false)
    log_in(non_admin)

    visit '/products/new'

    expect(current_path).to eq '/'
    expect(page).to have_content 'Access Denied'
  end

  scenario 'Users can leave reviews' do
    author = Author.create!(first_name: 'Arthur', last_name: 'Radcliffe')
    publisher = Publisher.create!(name: 'Arthur Books', city: 'Denver')
    product = Product.create!(
      name: 'Test Book',
      hardcover_price_in_cents: 1000,
      softcover_price_in_cents: 800,
      description: 'This is a description',
      image_url: 'http://fc04.deviantart.net/fs70/f/2012/306/d/c/fahrenheit_451__movie_poster_by_trzytrzy-d5jrq21.jpg',
      published_date: '1/1/2010',
      author_id: author.id,
      publisher_id: publisher.id
    )
    non_admin = User.create!(email: 'admin@example.com', password: 'password1', admin: false)
    log_in(non_admin)

    visit '/'
    click_on product.name
    fill_in 'what did you think?', with: 'Soooooo great'
    select '4', from: 'Stars'
    click_on 'Submit Review'
    expect(page).to have_content(non_admin.email)
    expect(page).to have_content('4 stars')
    expect(page).to have_content('Soooooo great')
  end

  scenario 'User sees validation errors for reviews' do
    author = Author.create!(first_name: 'Arthur', last_name: 'Radcliffe')
    publisher = Publisher.create!(name: 'Arthur Books', city: 'Denver')
    product = Product.create!(
      name: 'Test Book',
      hardcover_price_in_cents: 1000,
      softcover_price_in_cents: 800,
      description: 'This is a description',
      image_url: 'http://fc04.deviantart.net/fs70/f/2012/306/d/c/fahrenheit_451__movie_poster_by_trzytrzy-d5jrq21.jpg',
      published_date: '1/1/2010',
      author_id: author.id,
      publisher_id: publisher.id
    )
    non_admin = User.create!(email: 'admin@example.com', password: 'password1', admin: false)
    log_in(non_admin)

    visit '/'
    click_on product.name
    click_on 'Submit Review'
    expect(page).to have_content('Oh no! Your review was not shared with the world yet')
  end

end
