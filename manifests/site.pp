require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  class {
    'dnsmasq':
      tld => 'sugarcon.dev'
  }
  include git
  include hub
  #include nginx
  include dockutil
  include brewcask
  include wallpaper
  include osx::global::enable_dark_mode
  include osx::global::disable_remote_control_ir_receiver
  include osx::dock::autohide
  include osx::safari::enable_developer_mode

  # default ruby versions
  #ruby::version { '1.9.3': }
  #ruby::version { '2.0.0': }
  #ruby::version { '2.1.0': }
  #ruby::version { '2.1.1': }
  ruby::version { '2.1.2': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }


  homebrew::tap { 'caskroom/versions': }
  homebrew::tap { 'homebrew/php': }

  # some casks put symlinks in /usr/local/bin unfortunately
  ensure_resource(
    'file', '/usr/local', {
      ensure => 'directory',
      owner  => "${::luser}",
      group  => 'admin',
      mode   => '4775'
     }
  )
  ensure_resource(
    'file', '/usr/local/bin', {
      ensure => 'directory',
      owner  => "${::luser}",
      group  => 'admin',
      mode   => '4775',
      require => File['/usr/local']
     }
  )

 package {
    [
      "firefox",
      "google-chrome",
      "iterm2",
      "java",
      "sequel-pro",
      "sublime-text3",
    ]:
      provider => 'brewcask',
      require  => [ File['/usr/local/bin'], Homebrew::Tap['caskroom/versions'] ];
  }
  #mkdir /opt/boxen/homebrew/Cellar/percona-server/5.6.23-72.1/libexec

  package {
    [
      'coreutils',
      'dockutil',
      'memcached',
      'memcache-top',
      'percona-server',
      'pstree',
    ]:
      provider => 'homebrew',
  }

  package {
    [
      'composer',
      'php54',
      'php54-opcache',
      'php54-jsmin',
      'php54-memcached',
      'php54-mysqlnd_ms',
    ]:
      provider => 'homebrew',
      require  => Homebrew::Tap['homebrew/php']
  }

  package {
    'elasticsearch14':
      provider => 'homebrew',
      require  => [ Package['java'] ]
  }

  dockutil::item {
    'google-chrome':
      item     => "/Users/${::luser}/Applications/Google Chrome.app",
      label    => 'Google Chrome',
      action   => 'add',
      position => 2,
      require  => [ Package['google-chrome'], Package['dockutil'] ];
    'firefox':
      item     => "/Users/${::luser}/Applications/Firefox.app",
      label    => 'Firefox',
      action   => 'add',
      position => 3,
      require  => [ Package['firefox'], Package['dockutil'] ];
    'iterm2':
      item     => "/Users/${::luser}/Applications/iTerm.app",
      label    => 'iTerm',
      action   => 'add',
      position => 4,
      require  => [ Package['iterm2'], Package['dockutil'] ];
    'sequel-pro':
      item     => "/Users/${::luser}/Applications/Sequel Pro.app",
      label    => 'Sequel Pro',
      action   => 'add',
      position => 5,
      require  => [ Package['sequel-pro'], Package['dockutil'] ];
    'sublime-text3':
      item     => "/Users/${::luser}/Applications/Sublime Text.app",
      label    => 'Sublime Text',
      action   => 'add',
      position => 6,
      require  => [ Package['sublime-text3'], Package['dockutil'] ];
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

}
