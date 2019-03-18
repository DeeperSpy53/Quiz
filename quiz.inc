#if defined _quiz_included
    #endinput
#endif
#define _quiz_included

/**
 *
 * Игрок ответил правильно
 *	-
 * @param iClient 			Индекс игрока
 * @param iReward 			Вознаграждение(указывается в конфиге)
 *
 */
forward void Quiz_OnPlayerWin(int iClient);


/**
 *
 * Отлов генерации викторины
 *	-
 *
 */
forward void Quiz_OnQuizStart();

/**
 *
 * Объявление правильного ответа на викторину
 *	-
 *
 */
forward void Quiz_OnQuizEnd();