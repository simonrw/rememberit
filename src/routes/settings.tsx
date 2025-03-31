import { useEffect } from "react";

const SETTINGS_STORAGE_KEY = "rememberit-settings";

type Settings = {};

const defaultSettings = (): Settings => {
  return {};
};

export const Settings = () => {
  // const [settings, newSettings] = useState({});

  useEffect(() => {
    // load initial setgings
    const rawSettings = localStorage.getItem(SETTINGS_STORAGE_KEY);
    let settings;
    if (rawSettings === null) {
      settings = defaultSettings();
    } else {
      settings = JSON.parse(rawSettings) as Settings;
    }

    localStorage.setItem(SETTINGS_STORAGE_KEY, JSON.stringify(settings));
  }, []);

  return <div></div>;
};
