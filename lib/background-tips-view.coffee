_ = require 'underscore-plus'
{CompositeDisposable} = require 'atom'
$ = window.$ = window.jQuery = require 'jquery'

module.exports =
class BackgroundTipsElement extends HTMLElement
  disposables: null

  createdCallback: ->
    @disposables = new CompositeDisposable
    @disposables.add atom.workspace.onDidAddPane => @updateVisibility()
    @disposables.add atom.workspace.onDidDestroyPane => @updateVisibility()
    @disposables.add atom.workspace.onDidChangeActivePaneItem => @updateVisibility()
    @start()

  attachedCallback: ->
    paneView = atom.views.getView(atom.workspace.getActivePane())
    @innerHTML = @fullContent() paneView.offsetHeight
    window.addEventListener 'resize', => @updateSize()


  updateSize: ->
    paneView = atom.views.getView(atom.workspace.getActivePane())
    mainFrame = atom.views.getView atom.workspace
    bg = paneView.querySelector('#thera-background')
    bg.height = mainFrame.verticalAxis.offsetHeight if bg

  destroy: ->
    @disposables.dispose()

  shouldBeAttached: ->
    atom.workspace.getPanes().length is 1 and not atom.workspace.getActivePaneItem()?

  attach: ->
    paneView = atom.views.getView(atom.workspace.getActivePane())
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
