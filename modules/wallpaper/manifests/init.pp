class wallpaper
{
  file {
    "/Users/${::luser}/Documents/Wallpaper":
      ensure => directory,
      owner  => $::luser,
      group  => 'admin',
  }

  file {
    "/Users/${::luser}/Documents/Wallpaper/desktop_laptop_1440x900.jpg":
      owner   => $::luser,
      group   => 'admin',
      source  => 'puppet:///modules/wallpaper/desktop_laptop_1440x900.jpg',
      require => File["/Users/${::luser}/Documents/Wallpaper"];
    "/Users/${::luser}/Documents/Wallpaper/desktop_mobile_640x1136.jpg":
      owner   => $::luser,
      group   => 'admin',
      source  => 'puppet:///modules/wallpaper/desktop_mobile_640x1136.jpg',
      require => File["/Users/${::luser}/Documents/Wallpaper"];
    "/Users/${::luser}/Documents/Wallpaper/desktop_screen_1920x1080.jpg":
      owner   => $::luser,
      group   => 'admin',
      source  => 'puppet:///modules/wallpaper/desktop_screen_1920x1080.jpg',
      require => File["/Users/${::luser}/Documents/Wallpaper"];
  }
}
