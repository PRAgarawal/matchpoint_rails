var resourceModule = angular.module('ResourceModule', ['restangular', 'ngRoute']);

resourceModule.factory('resources', ['$rootScope', '$http', '$location', '$routeParams',
  '$timeout', 'Restangular', function ($rootScope, $http, $location, $routeParams, $timeout,
                                       Restangular) {

    Restangular.rootScope = $rootScope;
    Restangular.http = $http;
    Restangular.location = $location;
    Restangular.routeParams = $routeParams;
    Restangular.success_message = function(promise, message) {
      promise.success_message = message;
      return promise;
    };

    if (typeof CLIENT_USER_ID != "undefined" && CLIENT_USER_ID) {
      Restangular.setDefaultHeaders({"X-RU-client-user-id" : CLIENT_USER_ID});
    }

    // For some reason, Restangular doesn't support multiple error interceptors in their latest
    // Bower version, but it does in master.  We recreate it here until it's added to Restangular.
    var errorInterceptors = [];
    Restangular.addErrorInterceptor = function (interceptor) {
      errorInterceptors.push(interceptor);
    };
    Restangular.setErrorInterceptor(function (response, deferred, responseHandler) {
      for (var i = 0; i < errorInterceptors.length; i++) {
        errorInterceptors[i](response, deferred, responseHandler);
      }
    });

    Restangular.broadcast_validation_error = function(error_holder) {
      $rootScope.$broadcast('error', error_holder);
      check_for_error(error_holder);
    };

    // Validation interceptor
    Restangular.addErrorInterceptor(function (response, deferred, responseHandler) {
      toastr.options.closeButton = false;
      if (response.data && response.data.errors) {
        // Remove leading slash and trailing plural 's'
        var root = response.config.url.substr(1);
        if (root.indexOf('/') != -1) {
          root = root.substr(0, root.indexOf('/'));
        }
        if (root[root.length - 1] == 's') {
          root = root.substring(0, root.length - 1);
        }
        var errors = response.data.errors;
        for (var model in errors) {
          if (errors[model].length > 0) {
            var error = toTitleCase(errors[model][0]);
            var holder = {model: root + '.' + model, error: error, handled: false};
            Restangular.broadcast_validation_error(holder);
          }
        }
      } else {
        var serverErrorMsg, clientErrorMsg;
        if (typeof response.data == 'object' && response.data.custom_error) {
          serverErrorMsg = response.data.custom_error;
        }
        if (response.status == 401) {
          clientErrorMsg = "You have been signed out.  Please sign back in to continue.";
        } else if (response.status == 404) {
          $rootScope.notFoundMessage = serverErrorMsg ? serverErrorMsg :
              "We could not find the page you were looking for, perhaps an administrator deleted it.";
          return;
        } else if (response.status == 403) {
          clientErrorMsg = "You do not have access privileges.  Please contact your administrator.";
        } else {
          clientErrorMsg = "There was an internal error.  Please refresh and try again.";
        }
        toastr.error(serverErrorMsg ? serverErrorMsg : clientErrorMsg);
      }
    });

    var check_for_error = function (holder) {
      $timeout(function () {
        if (!holder.handled) {
          toastr.error(holder.model + ' ' + holder.error);
        }
      }, 0);
    };

    // Unsaved data interceptor
    // Variable stores callbacks to unregister locationChangeStart callbacks
    var unregisterCallbacks = {};
    Restangular.addResponseInterceptor(function (data, operation, what, url, response) {
      // Responses shouldn't be 200 when validation errors occur.
      if (response.status != 200) {
        return;
      }

      if (operation == 'get') {

      } else if (operation != "getList") {
        // This if enters mutation operations (not get or getList)
        if (url in unregisterCallbacks) {
          // If an object was mutated (saved or deleted), we shouldn't warn on location changes
          unregisterCallbacks[url]();
          delete unregisterCallbacks[url];
        }
      }

      return data;
    });

    function toTitleCase(str) {
      return str.replace(/\w\S*/g, function (txt) {
        return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
      });
    }

    // Progress spinner
    $rootScope.outstandingRequests = 0;
    function isExemptFromOutstandingUrlCounting(headers) {
      return headers.hasOwnProperty("X-RU-disable-spinner");
    }

    Restangular.addFullRequestInterceptor(function (elem, operation, path, url, headers,
                                                    params, httpConfig) {
      if (!isExemptFromOutstandingUrlCounting(headers)) {
        $rootScope.outstandingRequests++;
      }
    });

    function decrementOutstandingRequests(headers) {
      if (!isExemptFromOutstandingUrlCounting(headers)) {
        $rootScope.outstandingRequests--;
        if ($rootScope.outstandingRequests <= 0) {
          $rootScope.outstandingRequests = 0;
        }
      }
    }

    Restangular.addErrorInterceptor(function (response, deferred, responseHandler) {
      decrementOutstandingRequests(response.config.headers);
    });

    Restangular.addResponseInterceptor(function (data, operation, what, url, response, deferred) {
      decrementOutstandingRequests(response.config.headers);
      return data;
    });

    $rootScope.$on('$locationChangeStart', function (event, next, current) {
      // Re-set error message
      $rootScope.notFoundMessage = null;
    });

    return Restangular;
  }]);
