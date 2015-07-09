R = (require './rplus')
rooms = (require './rooms')
util = (require './util')

module.exports = {
  error: ((s)->
    s.error + """
      <a href="#office">Office</a>
    """)
  office: ((s)->
    s.currentCamera = ''
    mins = (Math.floor s.time / 60)
    secs = (util.pad 2, s.time % 60)
    door = s.locks.hall.office
    fan = s.locks.vent.office

    """
      Time: #{mins}:#{secs}  

      Power: #{s.power}

      Just a normal office

      The door is <a href="#door">#{if door then 'Closed' else 'Open'}</a>  
      The vent fan is <a href="#fan">#{if fan then 'On' else 'Off'}</a>

      <a href="#computer">Monitor the security cameras</a>.
    """)

  computer: ((s)->
    curCameraName = s.currentCamera or 'room'
    roomIndex = (rooms.getIndexByName curCameraName)
    monster = (R.find (R.propEq 'room', curCameraName), s.monsters)
    cameraIndex = (R.ifElse R.identity, (R.prop 'state'), (R.always 0))(monster)
    cameraLink = R.pipe(
      rooms.byName
      ((c)->
        if curCameraName is c.name
          """<span>#{c.name}</span>"""
        else
          """<a href="#camera?name=#{c.name}">#{c.name}</a>"""))

    arcade  = (cameraLink 'arcade')
    kitchen = (cameraLink 'kitchen')
    room    = (cameraLink 'room')
    hall    = (cameraLink 'hall')
    vent    = (cameraLink 'vent')

    curCameraHtml = rooms.rooms[roomIndex].states[cameraIndex](monster)
    map = """
        <pre>
                  +----------+
                  |          |
        +---------+  #{arcade}  |
        | #{kitchen} +          |
        +--+----------+--++--+
        | #{room}        |__||
        +--+-+--------+-- |
           | |           ||
           | | #{hall}      ||
           | |           || #{vent}
        +--+-+-----+_____||
        |  Office  |-----+
        +----------+
        </pre>
      """
    
    """
      <grid>
      <cell>#{map}</cell>
      <cell>
        <stack>
          <a href="#office">Turn off cameras</a>
          <centered><div>#{curCameraHtml}</div></centered>
        </stack>
      </cell>
    """)
  attack: ((s)->
    who = (R.prop 'name', (R.find (R.propEq 'room', 'office'), s.monsters))
    "<h1>HOLY CRAP #{who}'S GONNA KILL YOU!!!!!!!!!!!!!!!!!!!!!!!!!!!!</h1>")
  powerOut: ((s)->
    "Power out.....
    <h1>HOLY CRAP CADDY'S GONNA KILL YOU!!!!!!!!!!!!!!!!!!!!!!!!!!!!</h1>")
  win: ((s)->
    "You survived the night!")
}