var settingsModule = angular.module('SettingsModule', ['ngSanitize']);

settingsModule.config(['$routeProvider',
  function ($routeProvider) {
    $routeProvider.
    when('/settings', {
      templateUrl: 'main/settings/settings.html',
      controller: 'SettingsController as ctrl'
    }).
    when('/change_password', {
      templateUrl: 'main/settings/change_password.html',
      controller: 'ChangePasswordController as ctrl'
    });
  }]);

settingsModule.controller('SettingsController',
    ['$scope', function ($scope) {
      mixPanelEvts.navigateSettings();
    }]);

settingsModule.controller('ChangePasswordController',
    ['$scope', 'resources', 'matchpointModals', function ($scope, resources, matchpointModals) {
      mixPanelEvts.navigateChangePassword();
      var ctrl = this;

      ctrl.save = function () {
        // Custom put because user.put hits '/users/:id' and devise has route at '/users' for
        // changing password When you hit '/users' with a put, params[:user][:current_password]
        // must be present and correct to make changes
        // This is also the only way to change a password
        resources.one('users').customPUT({user: $scope.user}).then(function () {
          mixPanelEvts.changePassword();
          matchpointModals.genericConfirmation(null, "Password changed", "Success", "OK", true);
        }, function(){
          matchpointModals.genericConfirmation(null, 'Try again. Either your current password is not correct or your new password and confirm new password do not match', "Error", "OK", true);
        });
      };
    }]);
