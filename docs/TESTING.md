# WP1:n synteettinen testaus

Testi `tests/test_deac_index.py` lataa moduulin suhteellisesta polusta `DEAC-Frailty-Index/src/deac_index.py`. Se käyttää vain synteettisiä arvoja. Moduuli käyttää Pythonin vakiokirjastoa; testin ulkoinen riippuvuus on `pytest`. Tämä tiedosto ei määrää asentamaan pakettia globaaliin Pythoniin.

Ennen ajoa varmista, että käytössä on eristetty yhteensopiva Python-ympäristö ja sen `pytest`, sekä että kohderepossa ei ole testin automaattisesti lataamaa paikallista `conftest.py`-tiedostoa. Aja kohderepon juuresta ympäristön omalla Python-tulkilla:

```sh
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 .venv/bin/python -m pytest -q tests/test_deac_index.py
```

Kirjaa toteutunut tulkkipolku, Python- ja pytest-versiot, paluukoodi sekä kerättyjen, läpäisseiden, epäonnistuneiden ja ohitettujen testien määrät [WP1-katselmointiin](WP1_REVIEW.md). Jos pytest ei ole saatavilla, tila on `NOT RUN`; älä korvaa alkuperäistä testiä helpommalla testillä.

Testi kattaa muun muassa 80 prosentin kelpoisuusrajan molemmat puolet, tavallisen puuttuvuuden, vahvistetun ei-sovellettavuuden, tyhjän relevanttien komponenttien joukon sekä virheelliset arvot ja komponenttinimet. Testi ei tarkista lähdemuuttujien pisteytyssääntöjä eikä omistavan §3.1:n tieteellistä vastaavuutta.
