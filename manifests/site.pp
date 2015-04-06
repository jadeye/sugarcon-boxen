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
  include dnsmasq
  include git
  include hub
  #include nginx

  # fail if FDE is not enabled
  #if $::root_encrypted == 'no' {
  #  fail('Please enable full disk encryption and try again')
  #}

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

  include brewcask

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
      'composer',
      'memcached',
      'percona-server',
    ]:
      provider => 'homebrew',
  }

  package {
    [
      'php54',
      'php54-opcache',
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

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  include wallpaper
}
