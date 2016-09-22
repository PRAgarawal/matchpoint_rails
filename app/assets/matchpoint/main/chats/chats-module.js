var chatsModule = angular.module('ChatsModule', ['ngSanitize']);

chatsModule.config(['$routeProvider',
  function ($routeProvider) {
    $routeProvider.
    when('/chats/:chatId/:matchId', {
      templateUrl: 'main/chats/chat.html',
      controller: 'ChatController as ctrl'
    });
  }]);

chatsModule.controller('ChatController',
    ['$scope', 'resources', '$modal', function ($scope, resources, $modal) {
      var ctrl = this;
      var chatId = resources.routeParams.chatId;
      $scope.message = {chat_id: chatId};

      resources.one('matches/' + resources.routeParams.matchId).get().then(function (match) {
        $scope.match = match;
      });

      function getMessages() {
        resources.all('messages?chat_id=' + chatId).getList().then(function (messages) {
          $scope.messages = messages;
        });
      }

      ctrl.sendMessage = function() {
        var message = angular.copy($scope.message);
        $scope.message = {chat_id: chatId};
        resources.all('messages').post(message).then(function () {
          getMessages();
        });
      };

      ctrl.showUserModal = function(user) {
        openUserInfoModal(user, $modal, $scope, resources);
      };

      getMessages();
    }]);
