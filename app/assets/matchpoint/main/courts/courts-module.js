var courtsModule = angular.module('CourtsModule', ['ngSanitize']);

courtsModule.config(['$routeProvider',
  function ($routeProvider) {
    $routeProvider.
    when('/courts', {
      templateUrl: 'main/courts/courts.html',
      controller: 'CourtsListController as ctrl'
    });
  }]);

courtsModule.controller('CourtsListController',
    ['$scope', 'resources', '$modal', function ($scope, resources, $modal) {
      mixpanel.track("Navigate 'Courts'");
      var ctrl = this;
      
      function getCourts() {
        resources.all('courts?joined=true').getList().then(function (courts) {
          $scope.userCourts = courts;
        });
      }
      
      ctrl.showJoinCourtDialog = function () {
        $modal.open({
          templateUrl: 'main/courts/join_court_modal.html',
          controller: 'JoinCourtModalController as ctrl',
          'size': 'lg',
          'scope': $scope,
          'resources': resources
        }).result.then(function (reason) {
          if (reason == 'success') {
            getCourts();
          }
        });
      };

      ctrl.leaveCourt = function(court) {
        resources.all('courts/leave/' + court.id).customDELETE().then(function () {
          getCourts();
        });
      };

      getCourts();
    }]);

courtsModule.controller('JoinCourtModalController',
    ['$scope', '$modalInstance', 'resources', function ($scope, $modalInstance, resources) {
      var ctrl = this;

      resources.all('courts?joined=false').getList().then(function (courts) {
        $scope.courts = courts;
      });

      ctrl.joinCourt = function(court) {
        resources.all('courts/join/' + court.id).customPOST().then(function () {
          $modalInstance.close('success');
        });
      };

      ctrl.cancel = function() { $modalInstance.close('cancel'); }
    }]);
