angular.module('app', ['ngRoute', 'ui.bootstrap'])

.config(['$routeProvider', function($routeProvider) {
    $routeProvider.
      when('/', {
        templateUrl: '/public/templates/query.html',
        controller: 'QueryController'
      }).
      otherwise({ redirectTo: '/' });
}])

.controller('QueryController', [ '$scope', '$http', function($scope, $http) {
  var config,
      results,
      queryConfig = {
        rows: [],
        columns: [],
        computes: [],
        options: ['headers=true']
      };

  $http.get('/v1/resources/group-by').success(function(data) {
    $scope.config = data;
  });

  function addMember(array, member) {
    if (array.indexOf(member) === -1) {
      array.push(member);
    }
  }

  function removeMember(array, member) {
    var index = array.indexOf(member);
    if (index > -1) {
      array.splice(index, 1);
    }
  }

  angular.extend($scope, {
    config: config,
    results: results,
    queryConfig: queryConfig,
    addRow: function(member) {
      addMember($scope.queryConfig.rows, member);
    },
    addColumn: function(member) {
      addMember($scope.queryConfig.columns, member);
    },
    addCompute: function(member) {
      addMember($scope.queryConfig.computes, { ref: member, fn: '' });
    },
    removeRow: function(member) {
      removeMember($scope.queryConfig.rows, member);
    },
    removeColumn: function(member) {
      removeMember($scope.queryConfig.columns, member);
    },
    removeCompute: function(compute) {
      removeMember($scope.queryConfig.computes, compute);
    },
    selectCompute: function(compute, fn) {
      compute.fn = fn;
    },
    query: function() {
      $http.post('/v1/resources/group-by', queryConfig).success(function(data) {
        $scope.results = data;
      });
    }
  });
}]);
