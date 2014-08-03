app = Application.new
screen = Screen.new
piano_roll_view = PianoRollView.new(app, screen)
app.song.notes = TestHelper.deserialize('notes')

piano_roll_view.render
screen.getch
