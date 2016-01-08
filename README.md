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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elucid/mobiledoc-html-renderer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

