# Calendar

Source for https://abhchand.me/calendar/

### Setup

Download ics calendar file and place in folder

* Must be named `rna.ics`
* Only events tagged `[public]` will be included

### Build

```shell
rvm use
bundle install

ruby build.rb
```

### Run

```shell
python3 -m http.server --directory ./docs/ 9000
```

Open [http://localhost:9000/](http://localhost:9000/).
