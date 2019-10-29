# Highway
> [It's my way or the highway.](https://en.wikipedia.org/wiki/My_way_or_the_highway)

Highway combines what’s best about Bitrise and Fastlane into one tool. It is a build system built on top of Fastlane.

## Goal

* **Combine what's best of Bitrise.yml and Fastlane.** Highway prefers declarative configuration over convenience and takes advantage of a broad library of steps provided by Fastlane.
* **Reduce feedback loops.** Provide information faster and in more detail so that you don't waste time, especially when integrated with Danger.
* **Bring us closer to Continuous Delivery.** Highway allows to easily take advantage of existing tools to finally implement production CD in our projects.
* **Allow centralization of configuration.** Provide a first-party support to set default values and behaviors across projects. In the future, adding e.g. Carthage-Rome to our projects will be a matter of editing a central “default” configuration file in some repository. No more spreadsheets!

### Current status

Higway is currently at the beginning of its path. Few things needs to be done before the road will be open.

- [ ] Add Highway to two existing projects, to be used as a reference
- [ ] Publish public documentation
- [ ] Release version 1.0 and make a noise
- [ ] Make it clear that Highway is ready to be used in other projects.

### Getting started

For start [bundler](https://github.com/bundler/bundler) is required.

```
gem install bundler
```

Add Highway to your Gemfile.

```
gem "highway", git: "https://github.com/netguru/highway.git", branch: "develop"
```

Install dependencies.

```
bundle install
```

Create Fastfile in fastlane directory with the content:

```
import_from_git(
	url: "https://github.com/netguru/highway.git",
	branch: "develop"
)
```
Create Highwayfile and configure [steps](#available-steps).

```
touch Highwayfile.yml
```

Run the Highway by:

```
bundle exec fastlane highway
```

## Available steps

To be continued...

## Authors

* **[Adrian Kashivskyy](https://github.com/akashivskyy)** - *Initial work* - *Highway Foundations* -
* **[Piotr Sękara](https://github.com/piotr-sekara)** - *Steps* - *Unit Tests* - *Fixes* -

See also the list of [contributors](https://github.com/netguru/highway/contributors) who participated in this project.

## License

This project is licensed under the MIT License.