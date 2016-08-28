//= require ../matchpoint-widgets-module

(function() {
  var matchpointWidgets = angular.module('matchpointWidgetsModule');

  matchpointWidgets.service('matchpointModals', ['$modal', function ($modal) {
    return {
      deleteConfirmation: function (object, name, pathAfterSuccess, callback) {
        $modal.open({
          templateUrl: 'common/mp_modals/delete_confirmation_modal.html',
          controller: 'DeleteModalCtrl as ctrl',
          resolve: {
            'object': function () {
              return object;
            },
            'name': function () {
              return name;
            },
            'pathAfterSuccess': function () {
              return pathAfterSuccess;
            },
            'callback': function () {
              return callback;
            }
          }
        });
      },
      genericConfirmation: function (callback, message, title, buttonText, isInformational) {
        $modal.open({
          templateUrl: 'common/mp_modals/generic_confirmation_modal.html',
          controller: 'GenericModalCtrl as ctrl',
          resolve: {
            'callback': function () {
              return callback;
            },
            'message': function () {
              return message;
            },
            'title': function() {
              return title;
            },
            'buttonText': function() {
              return buttonText;
            },
            'isInformational': function() {
              return isInformational;
            }
          }
        });
      },
      error: function (message, title) {
        $modal.open({
          templateUrl: 'common/mp_modals/error_modal.html',
          controller: 'ErrorModalCtrl as ctrl',
          resolve: {
            'message': function () {
              return message;
            },
            'title': function() {
              return title;
            }
          }
        });
      }
    };
  }]);

  function dismiss(modalInstance) {
    modalInstance.dismiss('cancel');
  }

  matchpointWidgets.controller('DeleteModalCtrl',
      ['$scope', '$modalInstance', 'resources', 'object', 'name', 'pathAfterSuccess', 'callback',
        function ($scope, $modalInstance, resources, object, name, pathAfterSuccess, callback) {
          $scope.name = name;

          // IE8 doesn't like the keyword 'delete' in JS source files.  Workaround by setting it as
          // a string, just so we can load this file in IE8 for 'unsupported browser' modals.
          $scope['delete'] = function () {
            object.remove().then(function () {
              $modalInstance.dismiss('cancel');
              resources.location.path(pathAfterSuccess);
              if (callback) callback();
            });
          };
          $scope.cancel = function() {dismiss($modalInstance);}
        }]);

  matchpointWidgets.controller('GenericModalCtrl',
      ['$scope', '$modalInstance', 'callback', 'message', 'title', 'buttonText', 'isInformational',
      function ($scope, $modalInstance, callback, message, title, buttonText, isInformational) {
        message = message ? message : "save these changes";
        $scope.message = isInformational ? message : "Are you sure you want to " + message + "?";
        $scope.title = title ? title : "Confirm";
        $scope.buttonText = buttonText ? buttonText : "Submit";
        $scope.isInformational = isInformational;

        $scope.callback = function () {
          $modalInstance.dismiss('cancel');
          if (callback) callback();
        };
        $scope.cancel = function() {dismiss($modalInstance);}
      }]);

  matchpointWidgets.controller('ErrorModalCtrl',
      ['$scope, $modalInstance, message, title',
      function ($scope, $modalInstance, message, title) {
        $scope.message = message ? message : "An error occurred";
        $scope.title = title ? title : "Error";

        $scope.cancel = function() {dismiss($modalInstance);}
      }]);
})();
