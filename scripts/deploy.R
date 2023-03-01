#deploy to poissonconsulting server
rsconnect::deployApp(
  appDir = ".",
  account = "poissonconsulting",
  appName = "shinywqbench",
  forceUpdate = TRUE
)
