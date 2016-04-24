###* Copyright (C), DeltaSync Studios, 2010-2013. All rights reserved.
# ------------------------------------------------------------------
# File name:   password-check.js
# Version:     v1.00
# Created:     00:01 / 11.05.14
# Author:      Delta54 <support@e154.ru>
#
# This file is part of the CMS engine (http://e154.ru/).
#
# Your use and or redistribution of this software in source and / or
# binary form, with or without modification, is subject to: (i) your
# ongoing acceptance of and compliance with the terms and conditions of
# the DeltaSync License Agreement; and (ii) your inclusion of this notice
# in any version of this software that you use or redistribute.
# A copy of the DeltaSync License Agreement is available by contacting
# DeltaSync Studios. at http://e154.ru/
#
# Description:
# ------------------------------------------------------------------
# History:
#
###

do ->
  'use strict'
  Pc = 
    name: 'Pc'
    version: '1.2'
    passConfHidden: false
    password: ''
    init: (options) ->
      # имя пользователя
      Pc.username = $(options.nickname)
      # пароль
      Pc.passwordInput = $(options.passwordInput)
      if !Pc.passwordInput.length
        return
      # подтверждение пароля
      Pc.confirmInput = $(options.confirmInput)
      if !Pc.confirmInput.length
        return
      # рекомендации по паролю
      Pc.passwordRecommendation = $(options.passwordRecommendation)
      # проверка правильности ввода пароля
      passwordConfirmRecommendation = $(options.passwordConfirmRecommendation)
      # вывод текстовых рекомендаций
      Pc.strengthRecommendation = $(options.strengthRecommendation)
      # submit
      Pc.autoDisable = if undefined != options.autoDisable then options.autoDisable else true
      Pc.submit = $(options.submitButton)
      # блокировка сабмита
      if Pc.autoDisable
        Pc.submit.disabled = true
      passwordMeter = '<div class="password-strength"><div class="password-strength-text" aria-live="assertive"></div><div class="password-strength-title">Надёжность пароля:</div><div class="password-indicator"><div class="indicator"></div></div></div>'
      confirmMeter = '<div class="password-confirm">Совпадение паролей: <span class="error">нет</span></div>'
      @passwordRecommendation.html passwordMeter
      passwordConfirmRecommendation.html confirmMeter
      Pc.passConfMes = $('.password-confirm')
      Pc.strengthtext = @passwordRecommendation.find('.password-strength-text')
      Pc.indicator = @passwordRecommendation.find('.indicator')
      @Pc()
      @PcMatch()
      @passwordInput.keyup(Pc.Pc).focus(Pc.Pc).blur Pc.Pc
      @confirmInput.keyup(Pc.PcMatch).blur Pc.PcMatch
      return
    Pc: ->
      Pc.PcMatch()
      pass = Pc.password = Pc.passwordInput.val()
      weaknesses = 0
      strength = 100
      msg = []
      hasLowercase = /[a-z]+/.test(pass)
      hasUppercase = /[A-Z]+/.test(pass)
      hasNumbers = /[0-9]+/.test(pass)
      hasPunctuation = /[^a-zA-Z0-9]+/.test(pass)
      # длина пароля
      if pass.length < 6
        msg.push 'Используйте не менее 6 знаков'
        strength -= (6 - (pass.length)) * 5 + 30
      # нижний регистр
      if !hasLowercase
        msg.push 'Используйте знаки в нижнем регистре'
        weaknesses++
      # верхний регистр
      if !hasUppercase
        msg.push 'Используйте знаки в верхнем регистре'
        weaknesses++
      # цифры
      if !hasNumbers
        msg.push 'Используйте цифры'
        weaknesses++
      # Используйте пунктуацию
      if !hasPunctuation
        msg.push 'Используйте пунктуацию'
        weaknesses++
      # проверка совпадения пароля с именем пользователя
      if Pc.username != undefined
        if pass != '' and pass == Pc.username.val()
          msg.push 'Пароль не должен совпадать с именем'
          strength = 5
      # подсчет количества баллов
      switch weaknesses
        when 1
          strength -= 12.5
        when 2
          strength -= 25
        when 3
          strength -= 40
        when 4
          strength -= 40
      # подбор сообщения соответстующее количеству баллов
      if strength < 15
        Pc.strengthtext.html ''
      else if strength < 60
        Pc.strengthtext.html 'Слабый'
      else if strength < 70
        Pc.strengthtext.html 'Неплохой'
      else if strength < 80
        Pc.strengthtext.html 'Хорошо'
      else if strength <= 100
        Pc.strengthtext.html 'Сильный'
      if strength == 100
        Pc.strengthRecommendation.hide()
      else
        Pc.strengthRecommendation.show()
      # рендер
      msg = '<fieldset><legend><span>Улучшение надёжности пароля:</span></legend><ul><li>' + msg.join('</li><li>') + '</li></ul></fieldset>'
      Pc.strengthRecommendation.html msg
      Pc.indicator.css width: strength + '%'
      return
    PcMatch: ->
      # если поле пустое, скрыть подсказки и ждать
      if Pc.confirmInput.val().length == 0
        if Pc.passConfHidden == false
          Pc.passConfMes.css visibility: 'hidden'
          # блокировка сабмита
          if Pc.autoDisable
            Pc.submit.attr disabled: true
          Pc.passConfHidden = true
        return
      # в поле что-то появилось сравним с другим полем
      Pc.passConfHidden = false
      Pc.passConfMes.css visibility: 'visible'
      if Pc.password == Pc.confirmInput.val()
        Pc.passConfMes.children('span').removeClass('error').addClass('ok').html 'Да'
        # разблокировка сабмита
        if Pc.autoDisable
          Pc.submit.attr disabled: false
      else
        Pc.passConfMes.children('span').removeClass('ok').addClass('error').html 'Нет'
        # блокировка сабмита
        if Pc.autoDisable
          Pc.submit.attr disabled: true
      return

  angular
  .module('passwordCheck', [])
  .directive 'passwordCheck', ->
    {
      restrict: 'EA'
      link: ($scope, element, attrs) ->
        p = Pc
        options = 
          'nickname': attrs.nickname
          'passwordInput': attrs.passwordInput
          'confirmInput': attrs.confirmInput
          'passwordRecommendation': attrs.passwordRecommendation
          'passwordConfirmRecommendation': attrs.passwordConfirmRecommendation
          'strengthRecommendation': attrs.strengthRecommendation
          'submitButton': attrs.submitButton
          'autoDisable': attrs.autoDisable
        p.init options
        return

    }
  return
