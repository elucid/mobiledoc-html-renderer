# Mobiledoc HTML Renderer for Ruby

This is an HTML renderer for the [Mobiledoc format](https://github.com/bustlelabs/mobiledoc-kit/blob/master/MOBILEDOC.md) used by [Mobiledoc-Kit](https://github.com/bustlelabs/mobiledoc-kit).

To learn more about Mobiledoc cards and renderers, see the **[Mobiledoc Cards docs](https://github.com/bustlelabs/mobiledoc-kit/blob/master/CARDS.md)**

The implementation is based closely on https://github.com/bustlelabs/mobiledoc-html-renderer (kinda sorta a port to Ruby).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mobiledoc_html_renderer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mobiledoc_html_renderer

## Usage

```ruby
require 'mobiledoc_html_renderer'

mobiledoc = {
  "version" => "0.2.0",
  "sections" => [
    [ # markers
      ['B']
    ],
    [ # sections
      [1, 'P', [ # array of markups
        # markup
        [
          [0], # open markers (by index)
          0,   # close count
          'hello world'
        ]
      ]
    ]
  ]
}

renderer = Mobiledoc::HTMLRenderer.new(cards: [])
renderer.render(mobiledoc) # "<div><p><b>hello world</b></p></div>"
```
### Cards & Atoms

Define an object that responds to `#name`, `#type` and `#render`. Examples use a module but you can use whatever you like.
The `#render` method signatures is the only difference between cards & atoms.

```ruby
module TitleCard
  module_function

  # must match card name in mobiledoc document
  def name
    'title'
  end

  # must be 'html'
  def type
    'html'
  end

  # == Parameters:
  # env::
  #   A hash containing the key `:name` that will be equal to the name of the card/atom
  #
  # payload::
  #   The payload that was stored with this card/atom
  #
  # options::
  #   Options passed to the renderer at render time as `card_options`
  #
  # == Returns:
  # A string representing the card
  #
  def render(env, payload, options)
    "<h1 class='title'>#{payload['content']}</h1>"
  end
end

module MentionAtom
  module_function

  # must match atom name in mobiledoc document
  def name
    'mention'
  end

  # must be 'html'
  def type
    'html'
  end

  # == Parameters:
  # env::
  #   A hash containing the key `:name` that will be equal to the name of the atom
  #
  # value::
  #   The value that was stored with the atom
  #
  # payload::
  #   The payload that was stored with this atom
  #
  # options::
  #   Options passed to the renderer at render time as `card_options`
  #
  # == Returns:
  # A string representing the atom
  #
  def render(env, value, payload, options)
    "<span class='mention'>#{value}</span>"
  end
end

mobiledoc = ...
renderer = Mobiledoc::HTMLRenderer.new(cards: [TitleCard], atoms: [MentionAtom])
renderer.render(mobiledoc) # "<div><h1 class='title'>Oh hai</h1><span class='mention'>@sdhull</span></div>"
```

### Custom Element Renderers

As with the javascript dom renderer, you can define custom element renderers. In order to maintain symmetry with the js dom renderer, these are passed as two hashes, `section_element_renderer` and `markup_element_renderer`. Note that keys in these hashes must be uppercase.

#### section_element_renderer
If you render h1 tags in some special way, you might do it like this:

```ruby
# == Parameters:
# create_element::
#   A proc that accepts a tagname and will return a Nokogiri node.
#
# == Returns:
# MUST return the node created by `create_element`
#
h1_renderer = lambda do |create_element|
  element = create_element.call('h1')
  element.set_attribute('class', 'primary-title')
  element
end
renderer = Mobiledoc::HTMLRenderer.new(section_element_renderer: {'H1' => h1_renderer})
```

#### markup_element_renderer
For example, if you render strong tags in some special way, you might do it like this:

```ruby
# == Parameters:
# create_element::
#   A proc that accepts a tagname and will return a Nokogiri node.
#
# attributes::
#   Hash of attributes that were stored with that markup.
#
# == Returns:
# MUST return the node created by `create_element`
#
strong_renderer = lambda do |create_element, attributes|
  element = create_element.call('strong')
  weight = attributes['data-weight']
  element.set_attribute('class', "font-weight-#{weight}")
  element
end
renderer = Mobiledoc::HTMLRenderer.new(markup_element_renderer: {'STRONG' => strong_renderer})
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elucid/mobiledoc-html-renderer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

