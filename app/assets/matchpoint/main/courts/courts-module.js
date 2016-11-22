var courtsModule = angular.module('CourtsModule', ['ngSanitize']);

courtsModule.config(['$routeProvider',
  function ($routeProvider) {
    $routeProvider.
    when('/courts', {
      templateUrl: 'main/courts/courts.html',
      controller: 'CourtsListController as ctrl'
    }).
    when('/courts/new', {
      templateUrl: 'main/courts/new_court.html',
      controller: 'NewCourtController as ctrl'
    });
  }]);

courtsModule.controller('CourtsListController',
    ['$scope', 'resources', '$modal', function ($scope, resources, $modal) {
      mixPanelEvts.navigateCourts();
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
          mixPanelEvts.leaveCourt(court);
          getCourts();
        });
      };

      getCourts();
    }]);

courtsModule.controller('NewCourtController',
    ['$scope', 'resources', 'matchpointModals', function ($scope, resources, matchpointModals) {
      mixPanelEvts.navigateRequestCourt();
      var ctrl = this;
      $scope.court = {requested_by_id: $scope.user.id, postal_address: {}};
      
      ctrl.createCourt = function() {
        resources.all('courts').post($scope.court).then(function (court) {
          mixPanelEvts.courtRequestSubmit();
          matchpointModals.genericConfirmation(null, "Thanks for your submission! The court is now available to be joined by any user and matches can be scheduled there.", "Court request received!", "OK", true);
          resources.location.path('courts');
        });
      }
    }]);

courtsModule.controller('JoinCourtModalController',
    ['$scope', '$modalInstance', 'resources', function ($scope, $modalInstance, resources) {
      var ctrl = this;

      resources.all('courts?joined=false').getList().then(function (courts) {
        $scope.courts = courts;
      });

      ctrl.joinCourt = function(court) {
        resources.all('courts/join/' + court.id).customPOST().then(function () {
          mixPanelEvts.joinCourt(court);
          $scope.user.has_joined_courts = true;
          $modalInstance.close('success');
        });
      };

      ctrl.cancel = function() { $modalInstance.close('cancel'); }
    }]);
