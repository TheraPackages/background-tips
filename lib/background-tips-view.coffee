_ = require 'underscore-plus'
{CompositeDisposable} = require 'atom'
Tips = require './tips'
$ = window.$ = window.jQuery = require 'jquery'


Template = """
             <ul class="background-message">
               <li class="message"></li>
             </ul>
           """

module.exports =
class BackgroundTipsElement extends HTMLElement
    StartDelay: 1000
    DisplayDuration: 10000
    FadeDuration: 300

    createdCallback: ->
        @index = -1

        @disposables = new CompositeDisposable
        @disposables.add atom.workspace.onDidAddPane => @updateVisibility()
        @disposables.add atom.workspace.onDidDestroyPane => @updateVisibility()
        @disposables.add atom.workspace.onDidChangeActivePaneItem => @updateVisibility()
        @startTimeout = setTimeout((=> @start()), @StartDelay)

    attachedCallback: ->
        @innerHTML = Template
        @message = @querySelector('.message')

    destroy: ->
        @stop()
        @disposables.dispose()
        @destroyed = true

    attach: ->
        paneView = atom.views.getView(atom.workspace.getActivePane())
        top = paneView.querySelector('.item-views')?.offsetTop ? 0
        @style.top = top + 'px'
        paneView.appendChild(this)

    detach: ->
        @remove()

    updateVisibility: ->
        if @shouldBeAttached()
            @start()
        else
            @stop()

    shouldBeAttached: ->
        atom.workspace.getPanes().length is 1 and not atom.workspace.getActivePaneItem()?

    start: ->
        return if not @shouldBeAttached() or @interval?
        @renderTips()
        @randomizeIndex()
        @attach()
        @showNextTip()
        #@interval = setInterval((=> @showNextTip()), @DisplayDuration)

    stop: ->
        @remove()
        clearInterval(@interval) if @interval?
        clearTimeout(@startTimeout)
        clearTimeout(@nextTipTimeout)
        @interval = null

    randomizeIndex: ->
        len = Tips.length
        @index = Math.round(Math.random() * len) % len

    showNextTip: ->
        @index = ++@index % Tips.length
        @message.classList.remove('fade-in')
        @nextTipTimeout = setTimeout =>
            @message.innerHTML = Tips[@index]
            @message.classList.add('fade-in')
        , @FadeDuration

    renderTips: ->
        return if @tipsRendered
        for tip, i in Tips
            Tips[i] = @renderTip(tip)
        @tipsRendered = true

    renderTip: (str) ->
        path = require('path')
        templatepath  = path.join(atom.packages.loadedPackages['background-tips'].path, 'lib', 'tipsback.html')

        "
        <div class='tinybox_1'></div>
        <iframe runat='server' frameborder='no' border='0' marginwidth='0' marginheight='0' scrolling='no' allowtransparency='yes'  width='100%' height='1400px'  src='#{templatepath}'></iframe>

        "

    getKeyBindingForCurrentPlatform: (bindings) ->
        return unless bindings?.length
        return binding for binding in bindings when binding.selector.indexOf(process.platform) isnt -1
        return bindings[0]

module.exports = document.registerElement 'background-tips', prototype: BackgroundTipsElement.prototype
