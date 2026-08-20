abstract final class AppRoutes {
  AppRoutes._();

  static const welcome = '/welcome';
  static const home = '/home';
  static const settings = '/settings';
  static const ask = '/ask';
  static const create = '/create';
  static const pollDetail = '/polls/:code';
  static const pollResults = '/polls/:code/results';
  static const sharedPoll = '/p/:code';
  static const activity = '/me';
  static const myQuestions = '/me/questions';
  static const myVotes = '/me/votes';

  static String poll(String code) => '/polls/$code';
  static String results(String code) => '/polls/$code/results';
}
