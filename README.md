# Solidus Prismic

[Prismic.io](https://prismic.io) Client for use in Solidus based applications.
Prismic is a CMS Backend that can be used to suplement your site with additional
content. That content can be updated through Prismic allowing you to make changes
to your site without a deploy.

## Installation

Add solidus_prismic to your Gemfile:

```ruby
gem 'solidus_prismic'
```

Then, run bundle install.

Create an account and repository at [Prismic.io](https://prismic.io)

After that's done, you need to set additional environment variables:
```
# These values are found at: https://yourapp.prismic.io/settings/apps/
PRISMIC_API_URL=https://yourapp.prismic.io/api # Required
PRISMIC_ACCESS_TOKEN=123FAKE456 # Only required if using a private API or preview refs
```

## Example

Create a Repeatable Custom Type in Prismic called `Products`

Edit the Product Type using the JSON editor tab on the right and paste this:

```
{
  "Main" : {
    "uid" : {
      "type" : "UID",
      "config" : {
        "label" : "Product Slug",
        "placeholder" : "Product Slug"
      }
    },
    "title" : {
      "type" : "StructuredText",
      "config" : {
        "single" : "heading1",
        "label" : "Title",
        "placeholder" : "title"
      }
    },
    "description" : {
      "type" : "StructuredText",
      "config" : {
        "multi" : "paragraph, preformatted, heading1, heading2, heading3, heading4, heading5, heading6, strong, em, hyperlink, image, embed, list-item, o-list-item, o-list-item",
        "label" : "Description",
        "placeholder" : "Description"
      }
    }
  }
}
```

The UID field which will translate to the Product Slug in Solidus as a unique identifier and label.
The Title field gives allows for a custom Product Title
The Description field gives allows for a custom Product Description

Hit Save at the top.

Go to your Solidus app

Add `require PrismicHelper` to `Spree::ProductsController`:

```
# app/controllers/spree/products_controller_decorator.rb

Spree::ProductsController.class_eval do
  include PrismicHelper

  before_action :get_prismic_documents, only: :show

  ##
  # Retrieve Prismic Document for the current @product
  #
  def get_prismic_documents
    @prismic_document = prismic_api.get_by_uid 'products', @product.slug
  end
end
```

Now that you have your Prismic Document you can add that custom data to your Product page:

```
<%# views/spree/products/show.html.erb %>

<% cache [I18n.locale, current_pricing_options, @product] do %>
  <div data-hook="product_show" itemscope itemtype="http://schema.org/Product">
    <% @body_id = 'product-details' %>

    <div class="columns six alpha" data-hook="product_left_part">
      ...
    </div>

    <div class="columns ten omega" data-hook="product_right_part">
      <div class="row" data-hook="product_right_part_wrap">

        <div id="product-description" data-hook="product_description">

          <!-- Check for Custom Prismic Data or render from Database -->
          <h1 class="product-title" itemprop="name">
            <% if @prismic_document&.fragments['title'].present? %>
              <%= @prismic_document.fragments['title'].as_text %>
            <% else %>
              <%= @product.name %>
            <% end %>
          </h1>

          <div itemprop="description" data-hook="description">
            <% if @prismic_document&.fragments['description'].present? %>
              <%= @prismic_document.fragments['description'].as_text %>
            <% else %>
              <%= product_description(@product) rescue Spree.t(:product_has_no_description) %>
            <% end %>
          </div>
          <!-- End Prismic -->

          <div id="cart-form" data-hook="cart_form">
            <%= render partial: 'cart_form' %>
          </div>

        </div>

        <%= render partial: 'taxons' %>

      </div>
    </div>

  </div>
<% end %>
```

Use the `include PrismicHelper` on any file that you want to retrieve Prismic data from.

## Testing

First bundle your dependencies, then run `rake`. `rake` will default to building the dummy app if it does not exist, then it will run specs, and [Rubocop](https://github.com/bbatsov/rubocop) static code analysis. The dummy app can be regenerated by using `rake test_app`.

```shell
bundle
bundle exec rake
```

Copyright (c) 2017 Eric Saupe, released under the New BSD License
