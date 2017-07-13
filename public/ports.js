let app = Elm.Main.fullscreen();

app.ports.buildXls.subscribe(function(json) {
  let xls = json2xls(json);
  app.ports.xlsBuilt.send(btoa(xls));
});
