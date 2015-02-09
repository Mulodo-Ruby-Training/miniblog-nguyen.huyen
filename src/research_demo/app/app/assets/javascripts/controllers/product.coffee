# ---------------------------
# @: Huyen
# d: 15/02/06
# f: crud data on table product
# ---------------------------
app = angular.module("ProductStore",['angularUtils.directives.dirPagination'])
app.controller "ProductCtrl" ,($scope, Product) ->
  $product = new Product
  $scope.total = null
  $scope.currentPage = 1;
  $scope.pageSize = 10;
  $scope.key = ""
  $scope.addMore = false
  $scope.name = ""
  $scope.description = ""
  $scope.edit = 0

  $scope.initProducts = (key,newPage) ->
    $scope.currentPage = newPage
    $scope.key = key
    $product.getData($scope.key,$scope.currentPage).then (res)->
      if res
        $scope.list_products = res.list
        $scope.total = res.total
      return
  $scope.search = (key) ->
    $scope.key = key
    $scope.currentPage = 1
    $scope.initProducts($scope.key,$scope.currentPage)
    return
  $scope.add = () ->
    $scope.addMore = true
    return
  $scope.edit = (id) ->
    $scope.edit = id
  $scope.cancel_editProduct = () ->
    $scope.edit = 0
  $scope.editProduct = (id, name, description) ->
    $product.editData(id,name,description).then (res) ->
      $scope.initProducts($scope.key,$scope.currentPage)
      $scope.edit = 0
    return
  $scope.addProduct = (name, description) ->
    $product.addData(name,description).then (res) ->
      $scope.initProducts($scope.key,$scope.currentPage)
      $scope.addMore = false
    return
  $scope.del = (id) ->
    $product.delData(id).then (res) ->
      $scope.initProducts($scope.key,$scope.currentPage)
  return
  return
  # --- To do: get list data -------
.factory 'Product',  ($http,$q,Validate) ->
  'use strict'
  # -------------------------
  # static variables
  $validate = new Validate
  _url =
    search: '/api/api_product01'
    add: '/api/api_product02'
    del: '/api/api_product03'
    edit: '/api/api_product04'
  # ---------------------------------------------
  # public class
  Product = () ->
    product =
      getData: (key,page) ->
        deferred = $q.defer()
        $http.post(
          _url.search,
          type: key,
          page: page

        ).then (response) ->
          data = $validate.parseResult(response)
          deferred.resolve data.data
          return
        return deferred.promise

      addData: (name, description) ->
        deferred = $q.defer()
        $http.post(
          _url.add,
          name: name,
          description: description

        ).then (response) ->
          data = $validate.parseResult(response)
          deferred.resolve data.data
          return
        return deferred.promise
      editData: (id,name, description) ->
        deferred = $q.defer()
        $http.post(
          _url.edit,
          id: id,
          name: name,
          description: description

        ).then (response) ->
          data = $validate.parseResult(response)
          deferred.resolve data.data
          return
        return deferred.promise
      delData: (id) ->
        deferred = $q.defer()
        $http.post(
          _url.del,
          id: id
        ).then (response) ->
          data = $validate.parseResult(response)
          deferred.resolve data.data
          return
        return deferred.promise

  Product
# -------- To do: Validate data from server -------
.factory 'Validate',  () ->
  'use strict'
  # ---------------------------------------------
  # public class
  Validate = () ->
    validate =
      parseResult: (result, is_simple) ->
        result = result.data unless is_simple
        res =
          status: 1
          message: result.message
          data: {}
        unless typeof(result.status) is 'undefined'
          if result.status == 1
            res.data = result.data
          else
            res.status = result.status
            res.message = result.message
        else
          res.status = 0
          res.message = 'Error!'

        return res

  Validate
