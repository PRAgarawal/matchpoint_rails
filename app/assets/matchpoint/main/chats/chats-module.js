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
    ['$scope', 'resources', '$modal', 'matchpointModals', function ($scope, resources, $modal, matchpointModals) {
      var ctrl = this;
      var chatId = resources.routeParams.chatId;
      $scope.message = {chat_id: chatId};

      resources.one('matches/' + resources.routeParams.matchId).get().then(function (match) {
        mixPanelEvts.matchChatView(match);
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
          mixPanelEvts.matchMessageSend($scope.match);
          getMessages();
        });
      };

      ctrl.showUserModal = function(user) {
        openUserInfoModal(user, $modal, $scope, resources);
      };

      ctrl.leaveMatch = function () {
        leaveMatchModal(matchpointModals, resources, ctrl, $scope.match, 'from_match_detail', function(){
            resources.location.path('my_matches');
        });
      };
      
      ctrl.shouldShowName = function(message) {
        var i = $scope.messages.indexOf(message);
        var previousMessage = i < $scope.messages.length - 1 ? $scope.messages[i+1] : {user_id: -1};
        return (message.user_id != $scope.user.id) && (previousMessage.user_id != message.user_id);
      };
      
      getMessages();
    }]);
