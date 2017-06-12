_ = require 'underscore-plus'
{CompositeDisposable} = require 'atom'
$ = window.$ = window.jQuery = require 'jquery'

module.exports =
class BackgroundTipsElement extends HTMLElement
  disposables: null

  createdCallback: ->
    @disposables = new CompositeDisposable
    @disposables.add atom.workspace.getCenter().onDidAddPaneItem =>
      console.log 'onDidAddPane'
      @updateVisibility()
    @disposables.add atom.workspace.getCenter().onDidDestroyPaneItem =>
      console.log 'onDidDestroyPane'
      @updateVisibility()
    @disposables.add atom.workspace.getCenter().onDidChangeActivePaneItem =>
      console.log 'onDidChangeActivePaneItem'
      @updateVisibility()

    @start()

  attachedCallback: ->
    paneView = atom.views.getView(atom.workspace.getCenter().getActivePane())
    @innerHTML = @fullContent() paneView.offsetHeight
    window.addEventListener 'resize', => @updateSize()


  updateSize: ->
    paneView = atom.views.getView(atom.workspace.getCenter().getActivePane())
    mainFrame = atom.views.getView atom.workspace
    bg = paneView.querySelector('#thera-background')
    bg.height = mainFrame.verticalAxis.offsetHeight if bg

  destroy: ->
    @disposables.dispose()

  shouldBeAttached: ->
    panes = atom.workspace.getCenter().getPanes()
    cnt = 0
    for pane in panes
      continue unless pane
      items = pane.items
      continue unless items
      cnt += items.length
    return cnt == 0

  attach: ->
    paneView = atom.views.getView(atom.workspace.getCenter().getActivePane())
    mainFrame = atom.views.getView atom.workspace
    top = paneView.querySelector('.item-views')?.offsetTop ? 0
    @style.top = top + 'px'
    paneView.appendChild(this)
    @updateSize()

  detach: ->
    @remove()

  start: ->
    @updateVisibility()

  updateVisibility: ->
    # debugger
    if @shouldBeAttached()
      @attach()
    else
      @detach()

  fullContent: ->
    path = require('path')
    templatepath = path.join(atom.packages.loadedPackages['thera-background-tips'].path, 'lib', 'tipsback.html')
    itemCreate = (h) ->
      "
        <div class='tinybox_1'></div>
        <iframe id='thera-background' runat='server' frameborder='no' border='0' marginwidth='0' marginheight='0' scrolling='no' allowtransparency='yes'  width='100%' height='#{h}'  src='#{templatepath}'></iframe>
      "

module.exports = document.registerElement 'thera-background-tips', prototype: BackgroundTipsElement.prototype
