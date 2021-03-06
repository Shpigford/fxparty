# fx(party)

[fx(party)](https://fxparty.xyz) is a portfolio analysis tool for fx(hash)! See how much your portfolio is worth, what current trends are and more!

## Setup

You'll need:

- ruby >3 (specific version is in `Gemfile`)
- postgreql (if using stock `config/database.yml`)

```shell
cd fxparty
bundle install
rails db:setup
```

You can then run the rails web server:

```shell
bin/dev
```

And visit [https://localhost:3000](https://localhost:3000)

## Performance

The app uses Skylight to monitor performance.

[![View performance data on Skylight](https://badges.skylight.io/typical/YtMR4RJSeMTs.svg)](https://oss.skylight.io/app/applications/YtMR4RJSeMTs) [![View performance data on Skylight](https://badges.skylight.io/problem/YtMR4RJSeMTs.svg)](https://oss.skylight.io/app/applications/YtMR4RJSeMTs) [![View performance data on Skylight](https://badges.skylight.io/rpm/YtMR4RJSeMTs.svg)](https://oss.skylight.io/app/applications/YtMR4RJSeMTs)

## Contributing

It's still very early days for this so your mileage will vary here and lots of things will break.

But almost any contribution will be beneficial at this point. Check the [current Issues](https://github.com/Shpigford/fxparty/issues) to see where you can jump in!

If you've got an improvement, just send in a pull request!

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

If you've got feature ideas, simply [open a new issues](https://github.com/Shpigford/fxparty/issues/new)!

## License & Copyright

Released under the MIT license, see the [LICENSE](https://github.com/Shpigford/fxparty/blob/main/LICENSE) file. Copyright (c) Sabotage Media LLC.
