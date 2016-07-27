function addRouting(app){
  // Workaround to this bug: https://github.com/angular/angular.js/issues/1213
  app.run(['$route', angular.noop]);

  app.run(['$rootScope', '$route', function ($rootScope, $route) {
    // put $route on rootscope for highlighting of current tab
    $rootScope.$route = $route;
  }]);
}
