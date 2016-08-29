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
      var ctrl = this;
      $scope.data = {};
      
      function getCourts() {
        resources.all('courts?joined=true').getList().then(function (courts) {
          $scope.data.userCourts = courts;
        });
      }
      
      ctrl.showJoinCourtDialog = function () {
        $modal.open({
          templateUrl: 'main/courts/join_court_modal.html',
          controller: 'JoinCourtModalController as ctrl',
          'size': 'lg',
          'scope': $scope,
          'resources': resources
        }).result.then(function () {
          getCourts();
        });
      };

      ctrl.leaveCourt = function(court) {
        getCourts();
      };

      getCourts();
    }]);

courtsModule.controller('JoinCourtModalController',
    ['$scope', '$modalInstance', 'resources', function ($scope, $modalInstance, resources) {
      resources.all('courts?joined=false').getList().then(function (courts) {
        $scope.courts = courts;
      });

      $scope.cancel = function() { $modalInstance.dismiss('cancel'); }
    }]);
